package com.lifeos.backend.schedule.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.factory.ScheduleOccurrenceFactory;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.repository.ScheduleOccurrenceRepository;
import com.lifeos.backend.schedule.domain.service.ScheduleOccurrenceLifecycleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Command service for manual and direct occurrence actions.
 *
 * ScheduleOccurrence = real planned time block.
 */
@Service
@RequiredArgsConstructor
public class ScheduleOccurrenceCommandService {

    private final ScheduleOccurrenceRepository occurrenceRepository;
    private final ScheduleOccurrenceFactory occurrenceFactory;
    private final ScheduleOccurrenceLifecycleService lifecycleService;
    private final UserTimeService userTimeService;

    @Transactional
    public ScheduleOccurrence createManual(CreateScheduleOccurrenceCommand command) {
        validateCreateManual(command);

        LocalDateTime userNowLocal = resolveUserNowLocal(command.userId());

        ScheduleOccurrence occurrence = occurrenceFactory.createManual(
                command.userId(),
                command.title(),
                command.type(),
                command.description(),
                command.startDateTime(),
                command.endDateTime(),
                command.linkedTaskInstanceId(),
                command.linkedTaskTemplateId(),
                userNowLocal
        );

        return occurrenceRepository.save(occurrence);
    }

    @Transactional
    public ScheduleOccurrence activate(UUID userId, UUID occurrenceId) {
        ScheduleOccurrence occurrence = findOwnedOccurrence(userId, occurrenceId);
        lifecycleService.activate(occurrence, Instant.now());
        return occurrenceRepository.save(occurrence);
    }

    @Transactional
    public ScheduleOccurrence expire(UUID userId, UUID occurrenceId) {
        ScheduleOccurrence occurrence = findOwnedOccurrence(userId, occurrenceId);
        lifecycleService.expire(occurrence, Instant.now());
        return occurrenceRepository.save(occurrence);
    }

    @Transactional
    public ScheduleOccurrence cancel(UUID userId, UUID occurrenceId) {
        ScheduleOccurrence occurrence = findOwnedOccurrence(userId, occurrenceId);
        lifecycleService.cancel(occurrence, Instant.now());
        return occurrenceRepository.save(occurrence);
    }

    @Transactional
    public ScheduleOccurrence restoreToPlanned(UUID userId, UUID occurrenceId) {
        ScheduleOccurrence occurrence = findOwnedOccurrence(userId, occurrenceId);
        lifecycleService.restoreToPlanned(occurrence);
        return occurrenceRepository.save(occurrence);
    }

    @Transactional
    public void delete(UUID userId, UUID occurrenceId) {
        ScheduleOccurrence occurrence = findOwnedOccurrence(userId, occurrenceId);
        occurrenceRepository.deleteById(occurrence.getId());
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

    private LocalDateTime resolveUserNowLocal(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDateTime();
    }

    private void validateCreateManual(CreateScheduleOccurrenceCommand command) {
        if (command == null) {
            throw new IllegalArgumentException("CreateScheduleOccurrenceCommand is required");
        }

        if (command.userId() == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (command.title() == null || command.title().isBlank()) {
            throw new IllegalArgumentException("title is required");
        }

        if (command.startDateTime() == null || command.endDateTime() == null) {
            throw new IllegalArgumentException("startDateTime and endDateTime are required");
        }

        if (!command.startDateTime().isBefore(command.endDateTime())) {
            throw new IllegalArgumentException("startDateTime must be before endDateTime");
        }
    }

    public record CreateScheduleOccurrenceCommand(
            UUID userId,
            String title,
            String description,
            ScheduleBlockType type,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            UUID linkedTaskInstanceId,
            UUID linkedTaskTemplateId
    ) {
    }
}