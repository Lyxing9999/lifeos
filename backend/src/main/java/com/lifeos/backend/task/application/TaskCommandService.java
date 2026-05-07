package com.lifeos.backend.task.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.ScheduleQueryService;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.request.UpdateTaskRequest;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.TaskCompletion;
import com.lifeos.backend.task.domain.TaskCompletionRepository;
import com.lifeos.backend.task.domain.TaskRepository;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.task.domain.policy.TaskValidationPolicy;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import com.lifeos.backend.task.infrastructure.TaskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TaskCommandService {

    private final TaskRepository repository;
    private final TaskCompletionRepository completionRepository;
    private final TaskMapper mapper;
    private final TaskValidationPolicy validationPolicy;
    private final UserTimeService userTimeService;
    private final ScheduleQueryService scheduleQueryService;

    public TaskResponse create(CreateTaskRequest request) {
        Task task = mapper.toEntity(request);

        validateLinkedScheduleBelongsToUser(
                task.getUserId(),
                task.getLinkedScheduleBlockId());
        normalizePlanningShape(task);
        validationPolicy.validate(task);
        task.clearProgressIfNotProgressMode();

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse update(UUID userId, UUID taskId, UpdateTaskRequest request) {
        Task task = findOwnedTask(userId, taskId);

        if (request.getTitle() != null) {
            task.setTitle(request.getTitle());
        }

        if (request.getDescription() != null) {
            task.setDescription(request.getDescription());
        }

        if (request.getCategory() != null) {
            task.setCategory(request.getCategory());
        }

        if (request.getTaskMode() != null) {
            task.setTaskMode(request.getTaskMode());
        }

        if (request.getPriority() != null) {
            task.setPriority(request.getPriority());
        }

        if (request.getArchived() != null) {
            if (request.getArchived()) {
                task.archive();
            } else {
                task.restore();
            }
        }

        if (request.getTags() != null) {
            task.clearAndReplaceTags(request.getTags());
        }

        if (Boolean.TRUE.equals(request.getClearDueDate())) {
            task.setDueDate(null);
        } else if (request.getDueDate() != null) {
            task.setDueDate(request.getDueDate());
        }

        if (Boolean.TRUE.equals(request.getClearDueDateTime())) {
            task.setDueDateTime(null);
        } else if (request.getDueDateTime() != null) {
            task.setDueDateTime(request.getDueDateTime());
        }

        if (Boolean.TRUE.equals(request.getClearLinkedScheduleBlock())) {
            task.setLinkedScheduleBlockId(null);
        } else if (request.getLinkedScheduleBlockId() != null) {
            validateLinkedScheduleBelongsToUser(
                    userId,
                    request.getLinkedScheduleBlockId()
            );
            task.setLinkedScheduleBlockId(request.getLinkedScheduleBlockId());
        }

        if (Boolean.TRUE.equals(request.getClearRecurrence())) {
            task.setRecurrenceRule(TaskRecurrenceRule.none());
        } else if (request.getRecurrenceType() != null
                || request.getRecurrenceStartDate() != null
                || request.getRecurrenceEndDate() != null
                || request.getRecurrenceDaysOfWeek() != null) {

            TaskRecurrenceRule existing = task.getRecurrenceRule();

            task.setRecurrenceRule(new TaskRecurrenceRule(
                    request.getRecurrenceType() != null
                            ? request.getRecurrenceType()
                            : existing != null ? existing.getType() : null,
                    request.getRecurrenceStartDate() != null
                            ? request.getRecurrenceStartDate()
                            : existing != null ? existing.getStartDate() : null,
                    request.getRecurrenceEndDate() != null
                            ? request.getRecurrenceEndDate()
                            : existing != null ? existing.getEndDate() : null,
                    request.getRecurrenceDaysOfWeek() != null
                            ? request.getRecurrenceDaysOfWeek()
                            : existing != null ? existing.getDaysOfWeek() : null
            ));
        }

        if (request.getProgressPercent() != null) {
            task.setProgressPercent(request.getProgressPercent());
        }

        if (request.getStatus() != null) {
            applyStatusChange(userId, task, request.getStatus());
        }
        normalizePlanningShape(task);
        validationPolicy.validate(task);
        task.clearProgressIfNotProgressMode();

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse complete(UUID userId, UUID taskId, LocalDate date) {
        Task task = findOwnedTask(userId, taskId);
        LocalDate completionDate = resolveCompletionDate(userId, date);

        if (task.isRecurring()) {
            TaskCompletion completion = completionRepository
                    .findByTaskIdAndCompletionDate(task.getId(), completionDate)
                    .orElseGet(() -> {
                        TaskCompletion created = new TaskCompletion();
                        created.setUserId(userId);
                        created.setTaskId(task.getId());
                        created.setCompletionDate(completionDate);
                        return created;
                    });

            completion.setCompletedAt(Instant.now());
            completion.setClearedAt(null);

            TaskCompletion savedCompletion = completionRepository.save(completion);

            TaskResponse response = mapper.toResponse(task);
            return asCompletedOccurrence(response, savedCompletion);
        }

        task.completeForDate(completionDate);
        validationPolicy.validate(task);

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse reopen(UUID userId, UUID taskId, LocalDate date) {
        Task task = findOwnedTask(userId, taskId);

        if (task.isRecurring()) {
            LocalDate completionDate = resolveCompletionDate(userId, date);

            completionRepository.findByTaskIdAndCompletionDate(task.getId(), completionDate)
                    .ifPresent(completionRepository::delete);

            TaskResponse response = mapper.toResponse(task);
            return asOpenOccurrence(response);
        }

        task.reopen();
        validationPolicy.validate(task);
        task.clearProgressIfNotProgressMode();

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse pause(UUID userId, UUID taskId, LocalDate pauseUntil) {
        Task task = findOwnedTask(userId, taskId);

        if (pauseUntil != null) {
            task.pauseUntil(pauseUntil);
        } else {
            task.pause();
        }

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse resume(UUID userId, UUID taskId) {
        Task task = findOwnedTask(userId, taskId);
        task.resume();

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse archive(UUID userId, UUID taskId) {
        Task task = findOwnedTask(userId, taskId);
        task.archive();

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse restore(UUID userId, UUID taskId) {
        Task task = findOwnedTask(userId, taskId);
        task.restore();

        return mapper.toResponse(repository.save(task));
    }

    public void delete(UUID userId, UUID taskId) {
        Task task = findOwnedTask(userId, taskId);
        repository.deleteById(task.getId());
    }

    @Transactional
    public void clearDoneForDay(UUID userId, LocalDate date) {
        LocalDate targetDate = resolveCompletionDate(userId, date);

        clearNormalCompletedTasksForDay(userId, targetDate);
        clearRecurringCompletionsForDay(userId, targetDate);
    }

    private void clearNormalCompletedTasksForDay(UUID userId, LocalDate date) {
        List<Task> completedTasks = repository.findByUserIdAndArchivedFalse(userId)
                .stream()
                .filter(task -> task.getStatus() == TaskStatus.COMPLETED)
                .filter(task -> isNormalTaskRelevantOnDay(task, date))
                .toList();

        if (completedTasks.isEmpty()) {
            return;
        }

        completedTasks.forEach(Task::clearFromDone);
        repository.saveAll(completedTasks);
    }

    private boolean isNormalTaskRelevantOnDay(Task task, LocalDate date) {
        if (task == null || date == null) {
            return false;
        }

        if (task.isRecurring()) {
            return false;
        }

        if (task.getAchievedDate() != null) {
            return task.getAchievedDate().equals(date);
        }

        if (task.getDueDateTime() != null) {
            return task.getDueDateTime().toLocalDate().equals(date);
        }

        if (task.getDueDate() != null) {
            return task.getDueDate().equals(date);
        }

        return false;
    }

    private void clearRecurringCompletionsForDay(UUID userId, LocalDate date) {
        List<TaskCompletion> completions = completionRepository.findByUserIdAndCompletionDate(userId, date);

        if (completions.isEmpty()) {
            return;
        }

        completions.forEach(TaskCompletion::clearFromDone);
        completionRepository.saveAll(completions);
    }

    public TaskResponse complete(UUID userId, UUID taskId) {
        return complete(userId, taskId, null);
    }

    public TaskResponse reopen(UUID userId, UUID taskId) {
        return reopen(userId, taskId, null);
    }

    private void applyStatusChange(UUID userId, Task task, TaskStatus status) {
        if (status == TaskStatus.IN_PROGRESS) {
            task.start();
            return;
        }

        if (status == TaskStatus.COMPLETED) {
            task.completeForDate(resolveCompletionDate(userId, null));
            return;
        }

        task.setStatus(status);
        task.clearCompletion();
    }

    private LocalDate resolveCompletionDate(UUID userId, LocalDate date) {
        if (date != null) {
            return date;
        }

        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private TaskResponse asCompletedOccurrence(
            TaskResponse response,
            TaskCompletion completion) {
        response.setStatus(TaskStatus.COMPLETED);
        response.setCompletedAt(completion.getCompletedAt());
        response.setAchievedDate(completion.getCompletionDate());
        response.setDoneClearedAt(completion.getClearedAt());
        return response;
    }

    private TaskResponse asOpenOccurrence(TaskResponse response) {
        if (response.getStatus() == TaskStatus.COMPLETED) {
            response.setStatus(TaskStatus.TODO);
        }

        response.setCompletedAt(null);
        response.setAchievedDate(null);
        response.setDoneClearedAt(null);
        return response;
    }

    private Task findOwnedTask(UUID userId, UUID taskId) {
        Task task = repository.findById(taskId)
                .orElseThrow(() -> new NotFoundException("Task not found"));

        if (!task.getUserId().equals(userId)) {
            throw new NotFoundException("Task not found");
        }

        return task;
    }

    private void validateLinkedScheduleBelongsToUser(
            UUID userId,
            UUID linkedScheduleBlockId) {
        if (linkedScheduleBlockId == null) {
            return;
        }

        scheduleQueryService.getByIdForUser(userId, linkedScheduleBlockId);
    }
    private void normalizePlanningShape(Task task) {
        if (task == null) {
            return;
        }
        if (!task.isRecurring()) {
            return;
        }
        TaskRecurrenceRule recurrenceRule = task.getRecurrenceRule();
        if (recurrenceRule == null) {
            return;
        }
        if (recurrenceRule.getStartDate() == null) {
            LocalDate inferredStartDate = null;
            if (task.getDueDateTime() != null) {
                inferredStartDate = task.getDueDateTime().toLocalDate();
            } else if (task.getDueDate() != null) {
                inferredStartDate = task.getDueDate();
            }
            if (inferredStartDate != null) {
                task.setRecurrenceRule(new TaskRecurrenceRule(
                        recurrenceRule.getType(),
                        inferredStartDate,
                        recurrenceRule.getEndDate(),
                        recurrenceRule.getDaysOfWeek()
                ));
            }
        }
        task.setDueDate(null);
        task.setDueDateTime(null);
    }

}