package com.lifeos.backend.schedule.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.command.ScheduleSpawnerService.ScheduleSpawnResult;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleRecurrenceType;
import com.lifeos.backend.schedule.domain.enums.ScheduleTemplateStatus;
import com.lifeos.backend.schedule.domain.repository.ScheduleTemplateRepository;
import com.lifeos.backend.schedule.domain.service.ScheduleRecurrenceResolver;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

/**
 * Command service for ScheduleTemplate.
 *
 * ScheduleTemplate = planned time blueprint.
 */
@Service
@RequiredArgsConstructor
public class ScheduleTemplateCommandService {

    private static final int DEFAULT_SPAWN_PAST_DAYS = 1;
    private static final int DEFAULT_SPAWN_FUTURE_DAYS = 7;

    private final ScheduleTemplateRepository templateRepository;
    private final ScheduleRecurrenceResolver recurrenceResolver;
    private final ScheduleSpawnerService scheduleSpawnerService;
    private final UserTimeService userTimeService;

    @Transactional
    public ScheduleTemplateCommandResult create(CreateScheduleTemplateCommand command) {
        validateCreateCommand(command);

        ScheduleTemplate template = new ScheduleTemplate();

        template.setUserId(command.userId());
        template.setTitle(normalizeRequired(command.title(), "title"));
        template.setDescription(normalize(command.description()));
        template.setType(command.type() == null ? ScheduleBlockType.OTHER : command.type());

        template.setStartTime(command.startTime());
        template.setEndTime(command.endTime());

        template.setStatus(ScheduleTemplateStatus.ACTIVE);

        template.setRecurrenceType(command.recurrenceType() == null
                ? ScheduleRecurrenceType.NONE
                : command.recurrenceType());

        template.setRecurrenceStartDate(command.recurrenceStartDate() == null
                ? resolveUserToday(command.userId())
                : command.recurrenceStartDate());

        template.setRecurrenceEndDate(command.recurrenceEndDate());
        template.setRecurrenceDaysOfWeek(normalizeDays(command.recurrenceDaysOfWeek()));

        template.setColorKey(normalize(command.colorKey()));
        template.setExternalCalendarId(command.externalCalendarId());

        recurrenceResolver.validate(template);

        ScheduleTemplate saved = templateRepository.save(template);

        ScheduleSpawnResult spawnResult = spawnIfActive(saved);

        return new ScheduleTemplateCommandResult(saved, spawnResult);
    }

    @Transactional
    public ScheduleTemplateCommandResult update(
            UUID userId,
            UUID templateId,
            UpdateScheduleTemplateCommand command
    ) {
        ScheduleTemplate template = findOwnedTemplate(userId, templateId);

        boolean recurrenceOrWindowChanged = false;

        if (command.title() != null) {
            template.setTitle(normalizeRequired(command.title(), "title"));
        }

        if (command.description() != null) {
            template.setDescription(normalize(command.description()));
        }

        if (command.type() != null) {
            template.setType(command.type());
        }

        if (command.startTime() != null) {
            template.setStartTime(command.startTime());
            recurrenceOrWindowChanged = true;
        }

        if (command.endTime() != null) {
            template.setEndTime(command.endTime());
            recurrenceOrWindowChanged = true;
        }

        if (command.recurrenceType() != null) {
            template.setRecurrenceType(command.recurrenceType());
            recurrenceOrWindowChanged = true;
        }

        if (command.recurrenceStartDate() != null) {
            template.setRecurrenceStartDate(command.recurrenceStartDate());
            recurrenceOrWindowChanged = true;
        }

        if (command.clearRecurrenceEndDate()) {
            template.setRecurrenceEndDate(null);
            recurrenceOrWindowChanged = true;
        } else if (command.recurrenceEndDate() != null) {
            template.setRecurrenceEndDate(command.recurrenceEndDate());
            recurrenceOrWindowChanged = true;
        }

        if (command.recurrenceDaysOfWeek() != null) {
            template.setRecurrenceDaysOfWeek(normalizeDays(command.recurrenceDaysOfWeek()));
            recurrenceOrWindowChanged = true;
        }

        if (command.colorKey() != null) {
            template.setColorKey(normalize(command.colorKey()));
        }

        if (command.clearColorKey()) {
            template.setColorKey(null);
        }

        if (command.externalCalendarId() != null) {
            template.setExternalCalendarId(command.externalCalendarId());
        }

        if (command.clearExternalCalendarId()) {
            template.setExternalCalendarId(null);
        }

        recurrenceResolver.validate(template);

        ScheduleTemplate saved = templateRepository.save(template);

        ScheduleSpawnResult spawnResult = recurrenceOrWindowChanged
                ? spawnIfActive(saved)
                : null;

        return new ScheduleTemplateCommandResult(saved, spawnResult);
    }

    @Transactional
    public ScheduleTemplate pause(UUID userId, UUID templateId) {
        ScheduleTemplate template = findOwnedTemplate(userId, templateId);
        template.pause();
        return templateRepository.save(template);
    }

    @Transactional
    public ScheduleTemplate resume(UUID userId, UUID templateId) {
        ScheduleTemplate template = findOwnedTemplate(userId, templateId);
        template.resume();
        recurrenceResolver.validate(template);

        ScheduleTemplate saved = templateRepository.save(template);
        spawnIfActive(saved);

        return saved;
    }

    @Transactional
    public ScheduleTemplate archive(UUID userId, UUID templateId) {
        ScheduleTemplate template = findOwnedTemplate(userId, templateId);
        template.archive();
        return templateRepository.save(template);
    }

    @Transactional
    public ScheduleTemplate restore(UUID userId, UUID templateId) {
        ScheduleTemplate template = findOwnedTemplate(userId, templateId);
        template.restore();
        recurrenceResolver.validate(template);

        ScheduleTemplate saved = templateRepository.save(template);
        spawnIfActive(saved);

        return saved;
    }

    @Transactional
    public void delete(UUID userId, UUID templateId) {
        ScheduleTemplate template = findOwnedTemplate(userId, templateId);
        templateRepository.deleteById(template.getId());
    }

    private ScheduleSpawnResult spawnIfActive(ScheduleTemplate template) {
        if (template == null || !template.canSpawnOccurrences()) {
            return null;
        }

        LocalDate today = resolveUserToday(template.getUserId());

        return scheduleSpawnerService.spawnTemplateWindow(
                template.getUserId(),
                template.getId(),
                today.minusDays(DEFAULT_SPAWN_PAST_DAYS),
                today.plusDays(DEFAULT_SPAWN_FUTURE_DAYS)
        );
    }

    private ScheduleTemplate findOwnedTemplate(UUID userId, UUID templateId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }

        return templateRepository.findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Schedule template not found"));
    }

    private LocalDate resolveUserToday(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private void validateCreateCommand(CreateScheduleTemplateCommand command) {
        if (command == null) {
            throw new IllegalArgumentException("CreateScheduleTemplateCommand is required");
        }

        if (command.userId() == null) {
            throw new IllegalArgumentException("userId is required");
        }

        normalizeRequired(command.title(), "title");

        if (command.startTime() == null || command.endTime() == null) {
            throw new IllegalArgumentException("startTime and endTime are required");
        }

        if (!command.startTime().isBefore(command.endTime())) {
            throw new IllegalArgumentException("startTime must be before endTime");
        }
    }

    private String normalizeRequired(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(fieldName + " is required");
        }

        return value.trim();
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }

    private String normalizeDays(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }

        return java.util.Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(String::toUpperCase)
                .collect(java.util.stream.Collectors.joining(","));
    }

    public record CreateScheduleTemplateCommand(
            UUID userId,
            String title,
            String description,
            ScheduleBlockType type,

            LocalTime startTime,
            LocalTime endTime,

            ScheduleRecurrenceType recurrenceType,
            LocalDate recurrenceStartDate,
            LocalDate recurrenceEndDate,
            String recurrenceDaysOfWeek,

            String colorKey,
            UUID externalCalendarId
    ) {
    }

    public record UpdateScheduleTemplateCommand(
            String title,
            String description,
            ScheduleBlockType type,

            LocalTime startTime,
            LocalTime endTime,

            ScheduleRecurrenceType recurrenceType,
            LocalDate recurrenceStartDate,
            LocalDate recurrenceEndDate,
            boolean clearRecurrenceEndDate,
            String recurrenceDaysOfWeek,

            String colorKey,
            boolean clearColorKey,

            UUID externalCalendarId,
            boolean clearExternalCalendarId
    ) {
    }

    public record ScheduleTemplateCommandResult(
            ScheduleTemplate template,
            ScheduleSpawnResult spawnResult
    ) {
        public boolean spawnedOccurrences() {
            return spawnResult != null && spawnResult.occurrencesCreated() > 0;
        }
    }
}