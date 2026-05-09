package com.lifeos.backend.schedule.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.factory.RecurringScheduleSpawnFactory;
import com.lifeos.backend.schedule.application.factory.RecurringScheduleSpawnFactory.ScheduleSpawnPlan;
import com.lifeos.backend.schedule.domain.entity.ScheduleException;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleExceptionType;
import com.lifeos.backend.schedule.domain.repository.ScheduleExceptionRepository;
import com.lifeos.backend.schedule.domain.repository.ScheduleOccurrenceRepository;
import com.lifeos.backend.schedule.domain.repository.ScheduleTemplateRepository;
import com.lifeos.backend.schedule.infrastructure.event.ScheduleDomainEventPublisher;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Application service for spawning ScheduleOccurrence rows.
 *
 * Responsibility:
 * - find active ScheduleTemplate spawn candidates
 * - check existing occurrences
 * - respect skipped/cancelled/rescheduled ScheduleException rows
 * - create ScheduleOccurrence rows through RecurringScheduleSpawnFactory
 *
 * Important:
 * This service owns persistence.
 * Factories only build objects/plans.
 */
@Service
@RequiredArgsConstructor
public class ScheduleSpawnerService {

    private static final int DEFAULT_PAST_WINDOW_DAYS = 1;
    private static final int DEFAULT_FUTURE_WINDOW_DAYS = 7;

    private final ScheduleTemplateRepository templateRepository;
    private final ScheduleOccurrenceRepository occurrenceRepository;
    private final ScheduleExceptionRepository exceptionRepository;
    private final RecurringScheduleSpawnFactory recurringScheduleSpawnFactory;
    private final UserTimeService userTimeService;
    private final ScheduleDomainEventPublisher scheduleDomainEventPublisher;
    @Transactional
    public ScheduleSpawnResult spawnDefaultWindow(UUID userId) {
        LocalDate userToday = resolveUserToday(userId);

        return spawnWindow(
                userId,
                userToday.minusDays(DEFAULT_PAST_WINDOW_DAYS),
                userToday.plusDays(DEFAULT_FUTURE_WINDOW_DAYS)
        );
    }

    @Transactional
    public ScheduleSpawnResult spawnWindow(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        validateUserId(userId);
        validateWindow(windowStart, windowEnd);

        LocalDateTime userNowLocal = resolveUserNowLocal(userId);

        List<ScheduleTemplate> templates = templateRepository.findSpawnCandidates(
                userId,
                windowStart,
                windowEnd
        );

        int templatesScanned = 0;
        int occurrencesCreated = 0;
        int skippedByException = 0;
        int cancelledByException = 0;
        int ignoredExisting = 0;
        int rescheduled = 0;

        Set<UUID> createdOccurrenceIds = new HashSet<>();

        for (ScheduleTemplate template : templates) {
            templatesScanned++;

            SingleScheduleSpawnResult result = spawnForTemplate(
                    template,
                    windowStart,
                    windowEnd,
                    userNowLocal
            );

            occurrencesCreated += result.occurrencesCreated();
            skippedByException += result.skippedByException();
            cancelledByException += result.cancelledByException();
            ignoredExisting += result.ignoredExisting();
            rescheduled += result.rescheduled();
            createdOccurrenceIds.addAll(result.createdOccurrenceIds());
        }

        return new ScheduleSpawnResult(
                userId,
                windowStart,
                windowEnd,
                templatesScanned,
                occurrencesCreated,
                skippedByException,
                cancelledByException,
                ignoredExisting,
                rescheduled,
                createdOccurrenceIds.stream().toList()
        );
    }

    @Transactional
    public ScheduleSpawnResult spawnTemplateWindow(
            UUID userId,
            UUID templateId,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        validateUserId(userId);
        validateWindow(windowStart, windowEnd);

        ScheduleTemplate template = templateRepository.findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Schedule template not found"));

        SingleScheduleSpawnResult result = spawnForTemplate(
                template,
                windowStart,
                windowEnd,
                resolveUserNowLocal(userId)
        );

        return new ScheduleSpawnResult(
                userId,
                windowStart,
                windowEnd,
                1,
                result.occurrencesCreated(),
                result.skippedByException(),
                result.cancelledByException(),
                result.ignoredExisting(),
                result.rescheduled(),
                result.createdOccurrenceIds()
        );
    }

    private SingleScheduleSpawnResult spawnForTemplate(
            ScheduleTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd,
            LocalDateTime userNowLocal
    ) {
        if (template == null || !template.canSpawnOccurrences()) {
            return SingleScheduleSpawnResult.empty();
        }

        List<LocalDate> occurrenceDates = recurringScheduleSpawnFactory.getOccurrenceDates(
                template,
                windowStart,
                windowEnd
        );

        if (occurrenceDates.isEmpty()) {
            return SingleScheduleSpawnResult.empty();
        }

        List<ScheduleException> exceptions = exceptionRepository
                .findByTemplateIdAndOccurrenceDateBetween(
                        template.getId(),
                        windowStart,
                        windowEnd
                );

        Set<LocalDate> existingOccurrenceDates = findExistingOccurrenceDates(
                template.getId(),
                occurrenceDates,
                exceptions
        );

        ScheduleSpawnPlan plan = recurringScheduleSpawnFactory.buildSpawnPlan(
                template,
                windowStart,
                windowEnd,
                userNowLocal,
                existingOccurrenceDates,
                exceptions
        );

        if (!plan.hasOccurrencesToCreate()) {
            return new SingleScheduleSpawnResult(
                    0,
                    plan.skippedDates().size(),
                    plan.cancelledDates().size(),
                    plan.ignoredExistingDates().size(),
                    plan.rescheduledDates().size(),
                    List.of()
            );
        }

        List<ScheduleOccurrence> safeToCreate = plan.occurrencesToCreate()
                .stream()
                .filter(occurrence -> !alreadyExists(occurrence))
                .toList();

        if (safeToCreate.isEmpty()) {
            return new SingleScheduleSpawnResult(
                    0,
                    plan.skippedDates().size(),
                    plan.cancelledDates().size(),
                    plan.ignoredExistingDates().size() + plan.occurrencesToCreate().size(),
                    plan.rescheduledDates().size(),
                    List.of()
            );
        }

        List<ScheduleOccurrence> saved = occurrenceRepository.saveAll(safeToCreate);
        scheduleDomainEventPublisher.publishPlannedAll(saved);
        markRescheduleExceptionsApplied(exceptions, saved);

        return new SingleScheduleSpawnResult(
                saved.size(),
                plan.skippedDates().size(),
                plan.cancelledDates().size(),
                plan.ignoredExistingDates().size(),
                plan.rescheduledDates().size(),
                saved.stream().map(ScheduleOccurrence::getId).toList()
        );
    }

    private Set<LocalDate> findExistingOccurrenceDates(
            UUID templateId,
            List<LocalDate> occurrenceDates,
            List<ScheduleException> exceptions
    ) {
        Set<LocalDate> existing = new HashSet<>();

        for (LocalDate occurrenceDate : occurrenceDates) {
            if (occurrenceRepository.existsByTemplateIdAndOccurrenceDate(templateId, occurrenceDate)) {
                existing.add(occurrenceDate);
            }
        }

        /**
         * Important:
         * Rescheduled target occurrences are detached from templateId.
         * So repeated spawner runs should still skip if the exception already has a created occurrence.
         */
        if (exceptions != null) {
            exceptions.stream()
                    .filter(exception -> exception.getType() == ScheduleExceptionType.RESCHEDULED)
                    .filter(exception -> exception.getScheduleOccurrenceId() != null)
                    .map(ScheduleException::getOccurrenceDate)
                    .forEach(existing::add);
        }

        return existing;
    }

    private boolean alreadyExists(ScheduleOccurrence occurrence) {
        if (occurrence == null) {
            return true;
        }

        if (occurrence.getTemplateId() == null) {
            return false;
        }

        if (occurrence.getOccurrenceDate() == null) {
            return false;
        }

        return occurrenceRepository.existsByTemplateIdAndOccurrenceDate(
                occurrence.getTemplateId(),
                occurrence.getOccurrenceDate()
        );
    }

    private void markRescheduleExceptionsApplied(
            List<ScheduleException> exceptions,
            List<ScheduleOccurrence> savedOccurrences
    ) {
        if (exceptions == null || exceptions.isEmpty()) {
            return;
        }

        for (ScheduleOccurrence saved : savedOccurrences) {
            if (saved.getTemplateId() != null) {
                continue;
            }

            ScheduleException matching = exceptions.stream()
                    .filter(exception -> exception.getType() == ScheduleExceptionType.RESCHEDULED)
                    .filter(exception -> saved.getOccurrenceDate().equals(exception.getOccurrenceDate()))
                    .findFirst()
                    .orElse(null);

            if (matching == null) {
                continue;
            }

            matching.setScheduleOccurrenceId(saved.getId());
            matching.markApplied();
            exceptionRepository.save(matching);
        }
    }

    private LocalDate resolveUserToday(UUID userId) {
        ZoneId zoneId = userTimeService.getUserZoneId(userId);
        return Instant.now().atZone(zoneId).toLocalDate();
    }

    private LocalDateTime resolveUserNowLocal(UUID userId) {
        ZoneId zoneId = userTimeService.getUserZoneId(userId);
        return Instant.now().atZone(zoneId).toLocalDateTime();
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateWindow(LocalDate windowStart, LocalDate windowEnd) {
        if (windowStart == null) {
            throw new IllegalArgumentException("windowStart is required");
        }

        if (windowEnd == null) {
            throw new IllegalArgumentException("windowEnd is required");
        }

        if (windowEnd.isBefore(windowStart)) {
            throw new IllegalArgumentException("windowEnd must be on or after windowStart");
        }
    }

    private record SingleScheduleSpawnResult(
            int occurrencesCreated,
            int skippedByException,
            int cancelledByException,
            int ignoredExisting,
            int rescheduled,
            List<UUID> createdOccurrenceIds
    ) {
        static SingleScheduleSpawnResult empty() {
            return new SingleScheduleSpawnResult(0, 0, 0, 0, 0, List.of());
        }
    }

    public record ScheduleSpawnResult(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd,
            int templatesScanned,
            int occurrencesCreated,
            int skippedByException,
            int cancelledByException,
            int ignoredExisting,
            int rescheduled,
            List<UUID> createdOccurrenceIds
    ) {
    }
}