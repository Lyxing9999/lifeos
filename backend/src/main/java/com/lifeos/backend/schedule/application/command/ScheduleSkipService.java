package com.lifeos.backend.schedule.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
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
import java.util.UUID;

/**
 * Handles SKIP/CANCEL occurrence behavior.
 *
 * Existing occurrence:
 * - mark occurrence SKIPPED/CANCELLED
 * - create/update ScheduleException
 *
 * Future occurrence before spawn:
 * - create ScheduleException
 * - spawner later avoids creating original occurrence
 */
@Service
@RequiredArgsConstructor
public class ScheduleSkipService {

    private final ScheduleOccurrenceRepository occurrenceRepository;
    private final ScheduleTemplateRepository templateRepository;
    private final ScheduleExceptionRepository exceptionRepository;
    private final ScheduleOccurrenceLifecycleService lifecycleService;
    private final ScheduleDomainEventPublisher scheduleDomainEventPublisher;
    @Transactional
    public ScheduleOccurrence skipExistingOccurrence(
            UUID userId,
            UUID occurrenceId,
            String reason
    ) {
        ScheduleOccurrence occurrence = findOwnedOccurrence(userId, occurrenceId);

        lifecycleService.skip(occurrence, Instant.now());

        ScheduleOccurrence saved = occurrenceRepository.save(occurrence);

        scheduleDomainEventPublisher.publishSkipped(saved, reason);

        if (saved.getTemplateId() != null && saved.getOccurrenceDate() != null) {
            upsertException(saved, ScheduleExceptionType.SKIPPED, reason);
        }

        return saved;
    }

    @Transactional
    public ScheduleOccurrence cancelExistingOccurrence(
            UUID userId,
            UUID occurrenceId,
            String reason
    ) {
        ScheduleOccurrence occurrence = findOwnedOccurrence(userId, occurrenceId);

        lifecycleService.cancel(occurrence, Instant.now());

        ScheduleOccurrence saved = occurrenceRepository.save(occurrence);
        scheduleDomainEventPublisher.publishSkipped(saved, reason);
        if (saved.getTemplateId() != null && saved.getOccurrenceDate() != null) {
            upsertException(saved, ScheduleExceptionType.CANCELLED, reason);
        }

        return saved;
    }

    @Transactional
    public ScheduleException skipFutureOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        return createFutureException(
                userId,
                templateId,
                occurrenceDate,
                ScheduleExceptionType.SKIPPED,
                reason
        );
    }

    @Transactional
    public ScheduleException cancelFutureOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        return createFutureException(
                userId,
                templateId,
                occurrenceDate,
                ScheduleExceptionType.CANCELLED,
                reason
        );
    }

    @Transactional
    public ScheduleSkipResult skipOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        validateTemplateOwnership(userId, templateId);
        validateOccurrenceDate(occurrenceDate);

        ScheduleOccurrence existing = occurrenceRepository
                .findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate)
                .filter(occurrence -> occurrence.getUserId().equals(userId))
                .orElse(null);

        if (existing != null) {
            ScheduleOccurrence skipped = skipExistingOccurrence(
                    userId,
                    existing.getId(),
                    reason
            );

            return ScheduleSkipResult.existingOccurrence(skipped);
        }

        ScheduleException exception = skipFutureOccurrence(
                userId,
                templateId,
                occurrenceDate,
                reason
        );

        return ScheduleSkipResult.futureException(exception);
    }

    @Transactional
    public ScheduleSkipResult cancelOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        validateTemplateOwnership(userId, templateId);
        validateOccurrenceDate(occurrenceDate);

        ScheduleOccurrence existing = occurrenceRepository
                .findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate)
                .filter(occurrence -> occurrence.getUserId().equals(userId))
                .orElse(null);

        if (existing != null) {
            ScheduleOccurrence cancelled = cancelExistingOccurrence(
                    userId,
                    existing.getId(),
                    reason
            );

            return ScheduleSkipResult.existingOccurrence(cancelled);
        }

        ScheduleException exception = cancelFutureOccurrence(
                userId,
                templateId,
                occurrenceDate,
                reason
        );

        return ScheduleSkipResult.futureException(exception);
    }

    private ScheduleException createFutureException(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            ScheduleExceptionType type,
            String reason
    ) {
        validateTemplateOwnership(userId, templateId);
        validateOccurrenceDate(occurrenceDate);

        ScheduleException exception = exceptionRepository
                .findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate)
                .orElseGet(ScheduleException::new);

        exception.setUserId(userId);
        exception.setTemplateId(templateId);
        exception.setOccurrenceDate(occurrenceDate);
        exception.setType(type);
        exception.setReason(reason);
        exception.markApplied();

        return exceptionRepository.save(exception);
    }

    private void upsertException(
            ScheduleOccurrence occurrence,
            ScheduleExceptionType type,
            String reason
    ) {
        ScheduleException exception = exceptionRepository
                .findByTemplateIdAndOccurrenceDate(
                        occurrence.getTemplateId(),
                        occurrence.getOccurrenceDate()
                )
                .orElseGet(ScheduleException::new);

        exception.setUserId(occurrence.getUserId());
        exception.setTemplateId(occurrence.getTemplateId());
        exception.setOccurrenceDate(occurrence.getOccurrenceDate());
        exception.setScheduleOccurrenceId(occurrence.getId());
        exception.setType(type);
        exception.setReason(reason);
        exception.markApplied();

        exceptionRepository.save(exception);
    }

    private ScheduleOccurrence findOwnedOccurrence(UUID userId, UUID occurrenceId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (occurrenceId == null) {
            throw new IllegalArgumentException("occurrenceId is required");
        }

        return occurrenceRepository.findByIdForUser(userId, occurrenceId)
                .orElseThrow(() -> new NotFoundException("Schedule occurrence not found"));
    }

    private void validateTemplateOwnership(UUID userId, UUID templateId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }

        ScheduleTemplate template = templateRepository.findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Schedule template not found"));

        if (!template.canSpawnOccurrences()) {
            throw new IllegalArgumentException("Schedule template cannot spawn occurrences");
        }
    }

    private void validateOccurrenceDate(LocalDate occurrenceDate) {
        if (occurrenceDate == null) {
            throw new IllegalArgumentException("occurrenceDate is required");
        }
    }

    public record ScheduleSkipResult(
            boolean existingOccurrence,
            ScheduleOccurrence occurrence,
            ScheduleException exception
    ) {
        public static ScheduleSkipResult existingOccurrence(ScheduleOccurrence occurrence) {
            return new ScheduleSkipResult(true, occurrence, null);
        }

        public static ScheduleSkipResult futureException(ScheduleException exception) {
            return new ScheduleSkipResult(false, null, exception);
        }
    }
}