package com.lifeos.backend.schedule.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.factory.ScheduleOccurrenceFactory;
import com.lifeos.backend.schedule.domain.entity.ScheduleException;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleExceptionType;
import com.lifeos.backend.schedule.domain.repository.ScheduleExceptionRepository;
import com.lifeos.backend.schedule.domain.repository.ScheduleOccurrenceRepository;
import com.lifeos.backend.schedule.domain.repository.ScheduleTemplateRepository;
import com.lifeos.backend.schedule.domain.service.ScheduleOccurrenceLifecycleService;
import com.lifeos.backend.schedule.infrastructure.event.ScheduleDomainEventPublisher;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Handles schedule reschedule use cases.
 *
 * Existing occurrence:
 * - mark old occurrence RESCHEDULED
 * - create new target occurrence
 * - create/update ScheduleException
 *
 * Future occurrence before spawn:
 * - create ScheduleException(type = RESCHEDULED)
 * - spawner later creates the target occurrence
 */
@Service
@RequiredArgsConstructor
public class ScheduleRescheduleService {

    private final ScheduleOccurrenceRepository occurrenceRepository;
    private final ScheduleTemplateRepository templateRepository;
    private final ScheduleExceptionRepository exceptionRepository;
    private final ScheduleOccurrenceFactory occurrenceFactory;
    private final ScheduleOccurrenceLifecycleService lifecycleService;
    private final UserTimeService userTimeService;
    private final ScheduleDomainEventPublisher scheduleDomainEventPublisher;
    @Transactional
    public ScheduleRescheduleResult rescheduleExistingOccurrence(
            UUID userId,
            UUID occurrenceId,
            LocalDateTime targetStartDateTime,
            LocalDateTime targetEndDateTime,
            String reason
    ) {
        validateUserId(userId);
        validateTargetWindow(targetStartDateTime, targetEndDateTime);

        ScheduleOccurrence source = occurrenceRepository.findByIdForUser(userId, occurrenceId)
                .orElseThrow(() -> new NotFoundException("Schedule occurrence not found"));

        LocalDateTime userNowLocal = resolveUserNowLocal(userId);

        lifecycleService.markRescheduled(source, Instant.now());

        ScheduleOccurrence target = occurrenceFactory.createRescheduledTarget(
                source,
                targetStartDateTime,
                targetEndDateTime,
                userNowLocal
        );

        ScheduleOccurrence savedTarget = occurrenceRepository.save(target);

        source.setRescheduledToOccurrenceId(savedTarget.getId());
        ScheduleOccurrence savedSource = occurrenceRepository.save(source);
        scheduleDomainEventPublisher.publishRescheduled(
                savedSource,
                savedTarget,
                reason
        );
        scheduleDomainEventPublisher.publishPlanned(savedTarget);
        if (savedSource.getTemplateId() != null && savedSource.getOccurrenceDate() != null) {
            upsertRescheduleException(
                    savedSource,
                    savedTarget,
                    targetStartDateTime,
                    targetEndDateTime,
                    reason
            );
        }

        return new ScheduleRescheduleResult(
                savedSource,
                savedTarget
        );
    }

    @Transactional
    public ScheduleException rescheduleFutureOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            LocalDateTime targetStartDateTime,
            LocalDateTime targetEndDateTime,
            String reason
    ) {
        validateUserId(userId);
        validateOccurrenceDate(occurrenceDate);
        validateTargetWindow(targetStartDateTime, targetEndDateTime);

        ScheduleTemplate template = templateRepository.findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Schedule template not found"));

        if (!template.canSpawnOccurrences()) {
            throw new IllegalArgumentException("Schedule template cannot spawn occurrences");
        }

        ScheduleException exception = exceptionRepository
                .findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate)
                .orElseGet(ScheduleException::new);

        exception.setUserId(userId);
        exception.setTemplateId(templateId);
        exception.setOccurrenceDate(occurrenceDate);
        exception.setType(ScheduleExceptionType.RESCHEDULED);
        exception.setRescheduledDate(targetStartDateTime.toLocalDate());
        exception.setRescheduledStartDateTime(targetStartDateTime);
        exception.setRescheduledEndDateTime(targetEndDateTime);
        exception.setReason(reason);
        exception.markApplied();

        exception.validateRescheduleWindow();

        return exceptionRepository.save(exception);
    }

    private void upsertRescheduleException(
            ScheduleOccurrence source,
            ScheduleOccurrence target,
            LocalDateTime targetStartDateTime,
            LocalDateTime targetEndDateTime,
            String reason
    ) {
        ScheduleException exception = exceptionRepository
                .findByTemplateIdAndOccurrenceDate(
                        source.getTemplateId(),
                        source.getOccurrenceDate()
                )
                .orElseGet(ScheduleException::new);

        exception.setUserId(source.getUserId());
        exception.setTemplateId(source.getTemplateId());
        exception.setOccurrenceDate(source.getOccurrenceDate());
        exception.setScheduleOccurrenceId(source.getId());
        exception.setType(ScheduleExceptionType.RESCHEDULED);
        exception.setRescheduledDate(targetStartDateTime.toLocalDate());
        exception.setRescheduledStartDateTime(targetStartDateTime);
        exception.setRescheduledEndDateTime(targetEndDateTime);
        exception.setReason(reason);
        exception.markApplied();

        exception.validateRescheduleWindow();

        exceptionRepository.save(exception);

        target.setRescheduledFromOccurrenceId(source.getId());
    }

    private LocalDateTime resolveUserNowLocal(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDateTime();
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateOccurrenceDate(LocalDate occurrenceDate) {
        if (occurrenceDate == null) {
            throw new IllegalArgumentException("occurrenceDate is required");
        }
    }

    private void validateTargetWindow(
            LocalDateTime targetStartDateTime,
            LocalDateTime targetEndDateTime
    ) {
        if (targetStartDateTime == null || targetEndDateTime == null) {
            throw new IllegalArgumentException("targetStartDateTime and targetEndDateTime are required");
        }

        if (!targetStartDateTime.isBefore(targetEndDateTime)) {
            throw new IllegalArgumentException("targetStartDateTime must be before targetEndDateTime");
        }
    }

    public record ScheduleRescheduleResult(
            ScheduleOccurrence sourceOccurrence,
            ScheduleOccurrence targetOccurrence
    ) {
    }
}