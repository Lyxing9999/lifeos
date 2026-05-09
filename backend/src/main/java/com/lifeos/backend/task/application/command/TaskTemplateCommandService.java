package com.lifeos.backend.task.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.application.command.TaskSpawnerService.TaskSpawnResult;
import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.MissedPolicy;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.OverduePolicy;
import com.lifeos.backend.task.domain.enums.RolloverPolicy;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskTemplateStatus;
import com.lifeos.backend.task.domain.repository.MutationHistoryRepository;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

/**
 * Command service for TaskTemplate.
 *
 * TaskTemplate = blueprint / intent / recurrence rule.
 *
 * Important:
 * - Templates are not completed.
 * - Completion belongs to TaskInstance.
 * - Recurring templates spawn TaskInstances.
 */
@Service
@RequiredArgsConstructor
public class TaskTemplateCommandService {

    private static final int DEFAULT_SPAWN_PAST_DAYS = 1;
    private static final int DEFAULT_SPAWN_FUTURE_DAYS = 7;

    private final TaskTemplateRepository taskTemplateRepository;
    private final MutationHistoryRepository mutationHistoryRepository;
    private final TaskSpawnerService taskSpawnerService;
    private final UserTimeService userTimeService;

    /**
     * Create a task template.
     *
     * If it is recurring, this immediately spawns instances for a small window
     * so the user can dogfood without waiting for the engine.
     */
    @Transactional
    public TaskTemplateCommandResult create(CreateTaskTemplateCommand command) {
        validateCreateCommand(command);

        TaskTemplate template = new TaskTemplate();

        template.setUserId(command.userId());
        template.setTitle(normalizeRequired(command.title(), "title"));
        template.setDescription(normalize(command.description()));
        template.setStatus(TaskTemplateStatus.ACTIVE);
        template.setPriority(command.priority() == null ? TaskPriority.MEDIUM : command.priority());
        template.setCategory(normalize(command.category()));

        template.setRecurrenceType(command.recurrenceType() == null
                ? TaskRecurrenceType.NONE
                : command.recurrenceType());

        template.setRecurrenceStartDate(command.recurrenceStartDate());
        template.setRecurrenceEndDate(command.recurrenceEndDate());
        template.setRecurrenceDaysOfWeek(normalize(command.recurrenceDaysOfWeek()));

        template.setDefaultDueTime(command.defaultDueTime());
        template.setDefaultDurationMinutes(command.defaultDurationMinutes());
        template.setLinkedScheduleBlockId(command.linkedScheduleBlockId());

        template.setOverduePolicy(command.overduePolicy() == null
                ? OverduePolicy.OVERDUE_AT_END_OF_DAY
                : command.overduePolicy());

        template.setRolloverPolicy(command.rolloverPolicy() == null
                ? RolloverPolicy.KEEP_OVERDUE
                : command.rolloverPolicy());

        template.setMissedPolicy(command.missedPolicy() == null
                ? MissedPolicy.NEVER_MISS
                : command.missedPolicy());

        validateTemplate(template);

        TaskTemplate saved = taskTemplateRepository.save(template);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        saved.getUserId(),
                        saved.getId(),
                        null,
                        MutationType.TEMPLATE_CREATED,
                        null,
                        null,
                        null,
                        "USER",
                        "Task template created"
                )
        );

        TaskSpawnResult spawnResult = spawnIfRecurring(saved);

        return new TaskTemplateCommandResult(saved, spawnResult);
    }

    /**
     * Partial update.
     *
     * Null fields mean "no change".
     */
    @Transactional
    public TaskTemplateCommandResult update(
            UUID userId,
            UUID templateId,
            UpdateTaskTemplateCommand command
    ) {
        TaskTemplate template = findOwnedTemplate(userId, templateId);

        boolean recurrenceChanged = false;

        if (command.title() != null) {
            template.setTitle(normalizeRequired(command.title(), "title"));
        }

        if (command.description() != null) {
            template.setDescription(normalize(command.description()));
        }

        if (command.category() != null) {
            template.setCategory(normalize(command.category()));
        }

        if (command.priority() != null) {
            template.setPriority(command.priority());
        }

        if (command.recurrenceType() != null) {
            template.setRecurrenceType(command.recurrenceType());
            recurrenceChanged = true;
        }

        if (command.recurrenceStartDate() != null) {
            template.setRecurrenceStartDate(command.recurrenceStartDate());
            recurrenceChanged = true;
        }

        if (command.clearRecurrenceEndDate()) {
            template.setRecurrenceEndDate(null);
            recurrenceChanged = true;
        } else if (command.recurrenceEndDate() != null) {
            template.setRecurrenceEndDate(command.recurrenceEndDate());
            recurrenceChanged = true;
        }

        if (command.recurrenceDaysOfWeek() != null) {
            template.setRecurrenceDaysOfWeek(normalize(command.recurrenceDaysOfWeek()));
            recurrenceChanged = true;
        }

        if (command.clearDefaultDueTime()) {
            template.setDefaultDueTime(null);
        } else if (command.defaultDueTime() != null) {
            template.setDefaultDueTime(command.defaultDueTime());
        }

        if (command.clearDefaultDurationMinutes()) {
            template.setDefaultDurationMinutes(null);
        } else if (command.defaultDurationMinutes() != null) {
            template.setDefaultDurationMinutes(command.defaultDurationMinutes());
        }

        if (command.clearLinkedScheduleBlockId()) {
            template.setLinkedScheduleBlockId(null);
        } else if (command.linkedScheduleBlockId() != null) {
            template.setLinkedScheduleBlockId(command.linkedScheduleBlockId());
        }

        if (command.overduePolicy() != null) {
            template.setOverduePolicy(command.overduePolicy());
        }

        if (command.rolloverPolicy() != null) {
            template.setRolloverPolicy(command.rolloverPolicy());
        }

        if (command.missedPolicy() != null) {
            template.setMissedPolicy(command.missedPolicy());
        }

        validateTemplate(template);

        TaskTemplate saved = taskTemplateRepository.save(template);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        saved.getUserId(),
                        saved.getId(),
                        null,
                        recurrenceChanged
                                ? MutationType.RECURRENCE_CHANGED
                                : MutationType.TEMPLATE_UPDATED,
                        null,
                        null,
                        null,
                        "USER",
                        recurrenceChanged ? "Task template recurrence changed" : "Task template updated"
                )
        );

        TaskSpawnResult spawnResult = recurrenceChanged
                ? spawnIfRecurring(saved)
                : null;

        return new TaskTemplateCommandResult(saved, spawnResult);
    }

    @Transactional
    public TaskTemplate pause(UUID userId, UUID templateId, String reason) {
        TaskTemplate template = findOwnedTemplate(userId, templateId);
        template.pause();

        TaskTemplate saved = taskTemplateRepository.save(template);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        userId,
                        saved.getId(),
                        null,
                        MutationType.TEMPLATE_PAUSED,
                        null,
                        null,
                        null,
                        "USER",
                        reason == null ? "Task template paused" : reason
                )
        );

        return saved;
    }

    @Transactional
    public TaskTemplate resume(UUID userId, UUID templateId, String reason) {
        TaskTemplate template = findOwnedTemplate(userId, templateId);
        template.resume();

        validateTemplate(template);

        TaskTemplate saved = taskTemplateRepository.save(template);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        userId,
                        saved.getId(),
                        null,
                        MutationType.TEMPLATE_RESUMED,
                        null,
                        null,
                        null,
                        "USER",
                        reason == null ? "Task template resumed" : reason
                )
        );

        spawnIfRecurring(saved);

        return saved;
    }

    @Transactional
    public TaskTemplate archive(UUID userId, UUID templateId, String reason) {
        TaskTemplate template = findOwnedTemplate(userId, templateId);
        template.archive();

        TaskTemplate saved = taskTemplateRepository.save(template);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        userId,
                        saved.getId(),
                        null,
                        MutationType.TEMPLATE_ARCHIVED,
                        null,
                        null,
                        null,
                        "USER",
                        reason == null ? "Task template archived" : reason
                )
        );

        return saved;
    }

    @Transactional
    public TaskTemplate restore(UUID userId, UUID templateId, String reason) {
        TaskTemplate template = findOwnedTemplate(userId, templateId);
        template.restore();

        validateTemplate(template);

        TaskTemplate saved = taskTemplateRepository.save(template);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        userId,
                        saved.getId(),
                        null,
                        MutationType.TEMPLATE_RESTORED,
                        null,
                        null,
                        null,
                        "USER",
                        reason == null ? "Task template restored" : reason
                )
        );

        spawnIfRecurring(saved);

        return saved;
    }

    /**
     * Hard delete.
     *
     * For production dogfooding, prefer archive().
     */
    @Transactional
    public void delete(UUID userId, UUID templateId) {
        TaskTemplate template = findOwnedTemplate(userId, templateId);
        taskTemplateRepository.deleteById(template.getId());
    }

    private TaskSpawnResult spawnIfRecurring(TaskTemplate template) {
        if (template == null || !template.isActiveTemplate() || !template.isRecurring()) {
            return null;
        }

        LocalDate today = Instant.now()
                .atZone(userTimeService.getUserZoneId(template.getUserId()))
                .toLocalDate();

        return taskSpawnerService.spawnTemplateWindow(
                template.getUserId(),
                template.getId(),
                today.minusDays(DEFAULT_SPAWN_PAST_DAYS),
                today.plusDays(DEFAULT_SPAWN_FUTURE_DAYS)
        );
    }

    private TaskTemplate findOwnedTemplate(UUID userId, UUID templateId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }

        return taskTemplateRepository.findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Task template not found"));
    }

    private void validateCreateCommand(CreateTaskTemplateCommand command) {
        if (command == null) {
            throw new IllegalArgumentException("CreateTaskTemplateCommand is required");
        }

        if (command.userId() == null) {
            throw new IllegalArgumentException("userId is required");
        }

        normalizeRequired(command.title(), "title");
    }

    private void validateTemplate(TaskTemplate template) {
        if (template == null) {
            throw new IllegalArgumentException("TaskTemplate is required");
        }

        normalizeRequired(template.getTitle(), "title");

        if (template.getRecurrenceType() == null) {
            template.setRecurrenceType(TaskRecurrenceType.NONE);
        }

        if (template.getRecurrenceType().requiresStartDate()
                && template.getRecurrenceStartDate() == null) {
            throw new IllegalArgumentException("recurrenceStartDate is required for recurring template");
        }

        if (template.getRecurrenceType().requiresDaysOfWeek()
                && (template.getRecurrenceDaysOfWeek() == null
                || template.getRecurrenceDaysOfWeek().isBlank())) {
            throw new IllegalArgumentException("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }

        if (template.getRecurrenceStartDate() != null
                && template.getRecurrenceEndDate() != null
                && template.getRecurrenceEndDate().isBefore(template.getRecurrenceStartDate())) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }

        if (template.getDefaultDurationMinutes() != null
                && template.getDefaultDurationMinutes() <= 0) {
            throw new IllegalArgumentException("defaultDurationMinutes must be positive");
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

    public record CreateTaskTemplateCommand(
            UUID userId,
            String title,
            String description,
            TaskPriority priority,
            String category,

            TaskRecurrenceType recurrenceType,
            LocalDate recurrenceStartDate,
            LocalDate recurrenceEndDate,
            String recurrenceDaysOfWeek,

            LocalTime defaultDueTime,
            Integer defaultDurationMinutes,
            UUID linkedScheduleBlockId,

            OverduePolicy overduePolicy,
            RolloverPolicy rolloverPolicy,
            MissedPolicy missedPolicy
    ) {
    }

    public record UpdateTaskTemplateCommand(
            String title,
            String description,
            TaskPriority priority,
            String category,

            TaskRecurrenceType recurrenceType,
            LocalDate recurrenceStartDate,
            LocalDate recurrenceEndDate,
            boolean clearRecurrenceEndDate,
            String recurrenceDaysOfWeek,

            LocalTime defaultDueTime,
            boolean clearDefaultDueTime,
            Integer defaultDurationMinutes,
            boolean clearDefaultDurationMinutes,
            UUID linkedScheduleBlockId,
            boolean clearLinkedScheduleBlockId,

            OverduePolicy overduePolicy,
            RolloverPolicy rolloverPolicy,
            MissedPolicy missedPolicy
    ) {
    }

    public record TaskTemplateCommandResult(
            TaskTemplate template,
            TaskSpawnResult spawnResult
    ) {
        public boolean spawnedInstances() {
            return spawnResult != null && spawnResult.instancesCreated() > 0;
        }
    }
}