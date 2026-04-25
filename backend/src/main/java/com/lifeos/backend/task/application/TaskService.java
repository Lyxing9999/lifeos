package com.lifeos.backend.task.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.request.UpdateTaskRequest;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.api.response.TaskSectionResponse;
import com.lifeos.backend.task.domain.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TaskService {
    private final TaskRepository repository;
    private final TaskMapper mapper;
    private final TaskRecurrenceResolver recurrenceResolver;

    public TaskResponse create(CreateTaskRequest request) {
        validateProgressRules(request.getTaskMode(), request.getProgressPercent());
        validateRecurrence(request.getRecurrenceType(), request.getRecurrenceStartDate(), request.getRecurrenceEndDate(), request.getRecurrenceDaysOfWeek());

        Task task = mapper.toEntity(request);

        if (task.getTaskMode() != TaskMode.PROGRESS) {
            task.setProgressPercent(null);
        }

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse update(UUID taskId, UpdateTaskRequest request) {
        Task task = repository.findById(taskId)
                .orElseThrow(() -> new NotFoundException("Task not found"));

        if (request.getTitle() != null) task.setTitle(request.getTitle());
        if (request.getDescription() != null) task.setDescription(request.getDescription());
        if (request.getCategory() != null) task.setCategory(request.getCategory());
        if (request.getTaskMode() != null) task.setTaskMode(request.getTaskMode());
        if (request.getPriority() != null) task.setPriority(request.getPriority());
        if (request.getDueDate() != null) task.setDueDate(request.getDueDate());
        if (request.getDueDateTime() != null) task.setDueDateTime(request.getDueDateTime());
        if (request.getArchived() != null) task.setArchived(request.getArchived());
        if (request.getRecurrenceType() != null) task.setRecurrenceType(request.getRecurrenceType());
        if (request.getRecurrenceStartDate() != null) task.setRecurrenceStartDate(request.getRecurrenceStartDate());
        if (request.getRecurrenceEndDate() != null) task.setRecurrenceEndDate(request.getRecurrenceEndDate());
        if (request.getRecurrenceDaysOfWeek() != null) task.setRecurrenceDaysOfWeek(request.getRecurrenceDaysOfWeek());
        if (request.getLinkedScheduleBlockId() != null) task.setLinkedScheduleBlockId(request.getLinkedScheduleBlockId());
        if (request.getTags() != null) task.clearAndReplaceTags(request.getTags());

        validateProgressRules(task.getTaskMode(), request.getProgressPercent());
        validateRecurrence(task.getRecurrenceType(), task.getRecurrenceStartDate(), task.getRecurrenceEndDate(), task.getRecurrenceDaysOfWeek());

        if (request.getProgressPercent() != null) {
            task.setProgressPercent(task.getTaskMode() == TaskMode.PROGRESS ? request.getProgressPercent() : null);
        }

        if (request.getStatus() != null) {
            task.setStatus(request.getStatus());

            if (request.getStatus() == TaskStatus.IN_PROGRESS && task.getStartedAt() == null) {
                task.setStartedAt(Instant.now());
            }

            if (request.getStatus() == TaskStatus.COMPLETED) {
                task.setCompletedAt(Instant.now());
                if (task.getTaskMode() == TaskMode.PROGRESS && task.getProgressPercent() == null) {
                    task.setProgressPercent(100);
                }
            } else if (request.getStatus() != TaskStatus.COMPLETED) {
                task.setCompletedAt(null);
            }
        }

        if (task.getTaskMode() != TaskMode.PROGRESS) {
            task.setProgressPercent(null);
        }

        return mapper.toResponse(repository.save(task));
    }

    public TaskResponse complete(UUID taskId) {
        UpdateTaskRequest request = new UpdateTaskRequest();
        request.setStatus(TaskStatus.COMPLETED);
        return update(taskId, request);
    }

    public List<TaskResponse> getRelevantTasksByUserAndDay(UUID userId, LocalDate date, TaskFilterType filter) {
        return repository.findByUserIdAndArchivedFalse(userId).stream()
                .filter(task -> recurrenceResolver.isRelevantOn(task, date))
                .filter(task -> matchesFilter(task, filter))
                .sorted(taskComparator())
                .map(mapper::toResponse)
                .toList();
    }

    public List<TaskResponse> getByUserId(UUID userId, TaskFilterType filter) {
        return repository.findByUserIdAndArchivedFalse(userId).stream()
                .filter(task -> matchesFilter(task, filter))
                .sorted(taskComparator())
                .map(mapper::toResponse)
                .toList();
    }

    public TaskSectionResponse getSectionsForDay(UUID userId, LocalDate date, TaskFilterType filter) {
        List<TaskResponse> all = getRelevantTasksByUserAndDay(userId, date, filter);

        return TaskSectionResponse.builder()
                .urgentTasks(all.stream().filter(t -> t.getTaskMode() == TaskMode.URGENT).toList())
                .dailyTasks(all.stream().filter(t -> t.getTaskMode() == TaskMode.DAILY).toList())
                .progressTasks(all.stream().filter(t -> t.getTaskMode() == TaskMode.PROGRESS).toList())
                .standardTasks(all.stream().filter(t -> t.getTaskMode() == TaskMode.STANDARD).toList())
                .build();
    }

    public TaskResponse getTopActiveTask(UUID userId, LocalDate date) {
        return getRelevantTasksByUserAndDay(userId, date, TaskFilterType.ACTIVE).stream()
                .findFirst()
                .orElse(null);
    }

    public void delete(UUID taskId) {
        repository.deleteById(taskId);
    }

    public Comparator<Task> taskComparator() {
        return Comparator
                .comparing((Task task) -> task.getTaskMode() != TaskMode.URGENT)
                .thenComparing((Task task) -> task.getTaskMode() != TaskMode.DAILY)
                .thenComparing((Task task) -> task.getTaskMode() != TaskMode.PROGRESS)
                .thenComparing((Task task) -> task.getDueDateTime() == null)
                .thenComparing(Task::getDueDateTime, Comparator.nullsLast(LocalDateTime::compareTo))
                .thenComparing((Task task) -> task.getDueDate() == null)
                .thenComparing(Task::getDueDate, Comparator.nullsLast(LocalDate::compareTo))
                .thenComparing(Task::getTitle, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private boolean matchesFilter(Task task, TaskFilterType filter) {
        return switch (filter) {
            case ALL -> true;
            case ACTIVE -> task.getStatus() != TaskStatus.COMPLETED && task.getStatus() != TaskStatus.CANCELLED;
            case COMPLETED -> task.getStatus() == TaskStatus.COMPLETED;
        };
    }

    private void validateProgressRules(TaskMode taskMode, Integer progressPercent) {
        if (progressPercent == null) return;

        if (taskMode != TaskMode.PROGRESS) {
            throw new IllegalArgumentException("Progress percent is only allowed for PROGRESS tasks");
        }

        if (progressPercent < 0 || progressPercent > 100) {
            throw new IllegalArgumentException("Progress percent must be between 0 and 100");
        }
    }

    private void validateRecurrence(TaskRecurrenceType recurrenceType, LocalDate startDate, LocalDate endDate, String daysOfWeek) {
        if (recurrenceType == null) return;

        if (recurrenceType != TaskRecurrenceType.NONE && startDate == null) {
            throw new IllegalArgumentException("recurrenceStartDate is required for recurring task");
        }

        if (endDate != null && startDate != null && endDate.isBefore(startDate)) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }

        if (recurrenceType == TaskRecurrenceType.CUSTOM_WEEKLY && (daysOfWeek == null || daysOfWeek.isBlank())) {
            throw new IllegalArgumentException("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }
    }
}