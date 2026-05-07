package com.lifeos.backend.task.application;

import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.api.response.TaskSectionResponse;
import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.TaskCompletion;
import com.lifeos.backend.task.domain.TaskCompletionRepository;
import com.lifeos.backend.task.domain.TaskRepository;
import com.lifeos.backend.task.domain.enums.TaskFilterType;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.task.domain.policy.TaskSortPolicy;
import com.lifeos.backend.task.domain.service.TaskRecurrenceResolver;
import com.lifeos.backend.task.infrastructure.TaskMapper;
import com.lifeos.backend.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.lifeos.backend.task.domain.policy.TaskSurfacePolicy;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskQueryService {

        private final TaskRepository repository;
        private final TaskMapper mapper;
        private final TaskRecurrenceResolver recurrenceResolver;
        private final TaskSortPolicy sortPolicy;
        private final TaskCompletionRepository completionRepository;
        private final TaskSurfacePolicy surfacePolicy;
        public List<TaskResponse> getRelevantTasksByUserAndDay(UUID userId, LocalDate date, TaskFilterType filter) {
                // 1. Fetch potential tasks from the optimized repository query
                List<Task> allPotentialTasks = repository.findActiveAndRecurringTasks(userId);

                // 2. Filter by Recurrence Rules and SORT the Entities
                // This resolves the Comparator<? super TaskResponse> error
                List<Task> filteredAndSorted = allPotentialTasks.stream()
                        .filter(task -> recurrenceResolver.isRelevantOn(task, date))
                        .sorted(sortPolicy.comparator()) // Types match: Comparator<Task> sorting Stream<Task>
                        .toList();

                // 3. Map the sorted list to DTOs
                List<TaskResponse> responses = filteredAndSorted.stream()
                        .map(mapper::toResponse)
                        .toList();

                // 4. Apply completion overlay (TaskCompletion table) and final status filter
                // This handles cases where a Daily task is already finished today
                return applyRecurringCompletionState(userId, date, responses, filter);
        }
        public List<TaskResponse> getDayTruthTasks(UUID userId, LocalDate date) {

                Map<UUID, TaskResponse> byId = new LinkedHashMap<>();

                getDayActiveTasks(userId, date)

                                .forEach(task -> byId.put(task.getId(), task));

                getCompletedHistoryForDay(userId, date)

                                .forEach(task -> byId.put(task.getId(), task));

                return byId.values().stream().toList();

        }

        public List<TaskResponse> getDayActiveTasks(UUID userId, LocalDate date) {
                Map<UUID, TaskCompletion> completionsByTaskId = completionRepository
                                .findByUserIdAndCompletionDate(userId, date)
                                .stream()
                                .collect(Collectors.toMap(
                                                TaskCompletion::getTaskId,
                                                completion -> completion));

                return repository.findByUserIdAndArchivedFalse(userId)
                                .stream()
                                .filter(task -> surfacePolicy.shouldAppearInDayTruth(task, date))
                                .filter(task -> {
                                        if (!task.isRecurring()) {
                                                return true;
                                        }

                                        return !completionsByTaskId.containsKey(task.getId());
                                })
                                .sorted(sortPolicy.comparator())
                                .map(mapper::toResponse)
                                .toList();
        }

        public List<TaskResponse> getByUserId(UUID userId, TaskFilterType filter) {
                TaskFilterType safeFilter = filter == null ? TaskFilterType.ACTIVE : filter;

                if (safeFilter == TaskFilterType.ARCHIVED) {
                        return repository.findByUserIdAndArchivedTrue(userId)
                                        .stream()
                                        .sorted(sortPolicy.comparator())
                                        .map(mapper::toResponse)
                                        .toList();
                }

                return repository.findByUserIdAndArchivedFalse(userId)
                                .stream()
                                .filter(task -> matchesLibraryFilter(task, safeFilter))
                                .sorted(sortPolicy.comparator())
                                .map(mapper::toResponse)
                                .toList();
        }

        public List<TaskResponse> getInboxTasks(UUID userId) {
                return repository.findByUserIdAndArchivedFalse(userId)
                                .stream()
                                .filter(surfacePolicy::shouldAppearInInbox)
                                .sorted(sortPolicy.comparator())
                                .map(mapper::toResponse)
                                .toList();
        }

        public List<TaskResponse> getAnytimeTasks(UUID userId, TaskFilterType filter) {
                return getInboxTasks(userId);
        }

        public List<TaskResponse> getCompletedHistoryForDay(UUID userId, LocalDate date) {
                Map<UUID, TaskResponse> byId = new LinkedHashMap<>();

                Map<UUID, TaskCompletion> completionsByTaskId = completionRepository
                                .findByUserIdAndCompletionDate(userId, date)
                                .stream()
                                .collect(Collectors.toMap(
                                                TaskCompletion::getTaskId,
                                                completion -> completion));

                repository.findByUserIdAndArchivedFalse(userId)
                                .stream()
                                .filter(task -> task.getStatus() == TaskStatus.COMPLETED)
                                .filter(task -> !task.isRecurring())
                                .filter(task -> date.equals(task.getAchievedDate()))
                                .map(mapper::toResponse)
                                .forEach(task -> byId.put(task.getId(), task));

                repository.findByUserIdAndArchivedFalse(userId)
                                .stream()
                                .filter(Task::isRecurring)
                                .filter(task -> completionsByTaskId.containsKey(task.getId()))
                                .map(task -> {
                                        TaskResponse response = mapper.toResponse(task);
                                        TaskCompletion completion = completionsByTaskId.get(task.getId());
                                        response.setStatus(TaskStatus.COMPLETED);
                                        response.setCompletedAt(completion.getCompletedAt());
                                        response.setAchievedDate(completion.getCompletionDate());
                                        response.setDoneClearedAt(completion.getClearedAt());
                                        return response;
                                })
                                .forEach(task -> byId.putIfAbsent(task.getId(), task));

                return byId.values()
                                .stream()
                                .sorted(Comparator
                                                .comparing(
                                                                TaskResponse::getCompletedAt,
                                                                Comparator.nullsLast(Comparator.reverseOrder()))
                                                .thenComparing(
                                                                TaskResponse::getTitle,
                                                                Comparator.nullsLast(String::compareToIgnoreCase)))
                                .toList();
        }

        public List<TaskResponse> getPausedTasks(UUID userId) {
                return repository.findByUserIdAndArchivedFalse(userId)
                                .stream()
                                .filter(surfacePolicy::shouldAppearInPaused)
                                .sorted(sortPolicy.comparator())
                                .map(mapper::toResponse)
                                .toList();
        }

        public List<TaskResponse> getArchivedTasks(UUID userId, TaskFilterType filter) {

                return repository.findByUserIdAndArchivedTrue(userId)
                                .stream()
                                .filter(surfacePolicy::shouldAppearInArchived)
                                .sorted(sortPolicy.comparator())
                                .map(mapper::toResponse)
                                .toList();
        }

        public TaskSectionResponse getSectionsForDay(
                        UUID userId,
                        LocalDate date,
                        TaskFilterType filter) {
                List<TaskResponse> all = getRelevantTasksByUserAndDay(userId, date, filter);

                return TaskSectionResponse.builder()
                                .urgentTasks(all.stream()
                                                .filter(task -> task.getTaskMode() == TaskMode.URGENT)
                                                .toList())
                                .dailyTasks(all.stream()
                                                .filter(task -> task.getTaskMode() == TaskMode.DAILY)
                                                .toList())
                                .progressTasks(all.stream()
                                                .filter(task -> task.getTaskMode() == TaskMode.PROGRESS)
                                                .toList())
                                .standardTasks(all.stream()
                                                .filter(task -> task.getTaskMode() == TaskMode.STANDARD)
                                                .toList())
                                .build();
        }

        public TaskResponse getTopActiveTask(UUID userId, LocalDate date) {
                return getRelevantTasksByUserAndDay(userId, date, TaskFilterType.ACTIVE)
                                .stream()
                                .findFirst()
                                .orElse(null);
        }

        private List<TaskResponse> applyRecurringCompletionState(
                        UUID userId,
                        LocalDate date,
                        List<TaskResponse> tasks,
                        TaskFilterType filter) {
                TaskFilterType safeFilter = filter == null ? TaskFilterType.ALL : filter;

                Map<UUID, TaskCompletion> completionsByTaskId = completionRepository
                                .findByUserIdAndCompletionDate(userId, date)
                                .stream()
                                .collect(Collectors.toMap(
                                                TaskCompletion::getTaskId,
                                                completion -> completion));

                return tasks.stream()
                                .map(task -> applyRecurringCompletionState(task, completionsByTaskId))
                                .filter(task -> matchesDayFilter(task, safeFilter))
                                .filter(task -> shouldShowInDoneView(task, safeFilter))
                                .toList();
        }

        private TaskResponse applyRecurringCompletionState(
                        TaskResponse task,
                        Map<UUID, TaskCompletion> completionsByTaskId) {
                if (!isRecurring(task)) {
                        return task;
                }

                TaskCompletion completion = completionsByTaskId.get(task.getId());

                if (completion != null) {
                        task.setStatus(TaskStatus.COMPLETED);
                        task.setCompletedAt(completion.getCompletedAt());
                        task.setAchievedDate(completion.getCompletionDate());
                        task.setDoneClearedAt(completion.getClearedAt());
                } else {
                        task.setStatus(TaskStatus.TODO);
                        task.setCompletedAt(null);
                        task.setAchievedDate(null);
                        task.setDoneClearedAt(null);
                }

                return task;
        }

        private boolean shouldShowInDoneView(TaskResponse task, TaskFilterType filter) {
                if (filter != TaskFilterType.COMPLETED) {
                        return true;
                }

                return task.getDoneClearedAt() == null;
        }

        private boolean isInboxTask(Task task) {
                return task.getDueDate() == null
                                && task.getDueDateTime() == null
                                && task.getLinkedScheduleBlockId() == null
                                && !task.isRecurring()
                                && !Boolean.TRUE.equals(task.getArchived())
                                && !Boolean.TRUE.equals(task.getPaused())
                                && task.getStatus() != TaskStatus.COMPLETED
                                && task.getStatus() != TaskStatus.CANCELLED;
        }

        private boolean isRecurring(TaskResponse task) {
                return task.getRecurrenceType() != null
                                && !task.getRecurrenceType().name().equals("NONE");
        }

        private boolean matchesLibraryFilter(Task task, TaskFilterType filter) {
                return switch (filter) {
                        case ALL -> true;
                        case ACTIVE -> task.getStatus() != TaskStatus.COMPLETED
                                        && task.getStatus() != TaskStatus.CANCELLED
                                        && !Boolean.TRUE.equals(task.getPaused());
                        case COMPLETED -> task.getStatus() == TaskStatus.COMPLETED;
                        case ARCHIVED -> Boolean.TRUE.equals(task.getArchived());
                };
        }

        private boolean matchesArchivedStatusFilter(Task task, TaskFilterType filter) {
                return switch (filter) {
                        case ALL, ARCHIVED -> true;
                        case ACTIVE -> task.getStatus() != TaskStatus.COMPLETED
                                        && task.getStatus() != TaskStatus.CANCELLED;
                        case COMPLETED -> task.getStatus() == TaskStatus.COMPLETED;
                };
        }

        private boolean matchesDayFilter(TaskResponse task, TaskFilterType filter) {
                return switch (filter) {
                        case ALL -> true;
                        case ACTIVE -> task.getStatus() != TaskStatus.COMPLETED
                                        && task.getStatus() != TaskStatus.CANCELLED;
                        case COMPLETED -> task.getStatus() == TaskStatus.COMPLETED;
                        case ARCHIVED -> Boolean.TRUE.equals(task.getArchived());
                };
        }

        public TaskResponse getByIdForUser(UUID userId, UUID taskId, LocalDate date) {
                Task task = repository.findById(taskId)
                        .orElseThrow(() -> new NotFoundException("Task not found"));
                if (!task.getUserId().equals(userId)) {
                        throw new NotFoundException("Task not found");
                }
                TaskResponse response = mapper.toResponse(task);
                if (date != null && task.isRecurring()) {
                        completionRepository.findByTaskIdAndCompletionDate(taskId, date)
                                .ifPresent(completion -> {
                                        response.setStatus(TaskStatus.COMPLETED);
                                        response.setCompletedAt(completion.getCompletedAt());
                                        response.setAchievedDate(completion.getCompletionDate());
                                        response.setDoneClearedAt(completion.getClearedAt());
                                });
                }

                return response;
        }
        public List<TaskResponse> getDueTasks(UUID userId, LocalDate date) {
                Map<UUID, TaskCompletion> completionsByTaskId = date == null
                                ? Map.of()
                                : completionRepository.findByUserIdAndCompletionDate(userId, date)
                                                .stream()
                                                .collect(Collectors.toMap(
                                                                TaskCompletion::getTaskId,
                                                                completion -> completion));

                return repository.findByUserIdAndArchivedFalse(userId).stream()
                                .filter(surfacePolicy::shouldAppearInDue)
                                .filter(task -> {
                                        if (!task.isRecurring()) {
                                                return true;
                                        }

                                        if (date == null) {
                                                return true;
                                        }

                                        return !completionsByTaskId.containsKey(task.getId());
                                })
                                .sorted(sortPolicy.comparator())
                                .map(mapper::toResponse)
                                .toList();
        }

        public List<TaskResponse> getDoneTasks(UUID userId, LocalDate date) {
                Map<UUID, TaskCompletion> completionsByTaskId = completionRepository
                                .findByUserIdAndCompletionDate(userId, date)
                                .stream()
                                .collect(Collectors.toMap(
                                                TaskCompletion::getTaskId,
                                                completion -> completion));

                List<TaskResponse> normalDone = repository.findByUserIdAndArchivedFalse(userId)
                                .stream()
                                .filter(task -> !task.isRecurring())
                                .filter(task -> surfacePolicy.shouldAppearInDone(task, date))
                                .map(mapper::toResponse)
                                .toList();

                List<TaskResponse> recurringDone = repository.findByUserIdAndArchivedFalse(userId)
                                .stream()
                                .filter(Task::isRecurring)
                                .filter(task -> completionsByTaskId.containsKey(task.getId()))
                                .map(task -> {
                                        TaskCompletion completion = completionsByTaskId.get(task.getId());
                                        TaskResponse response = mapper.toResponse(task);
                                        response.setStatus(TaskStatus.COMPLETED);
                                        response.setCompletedAt(completion.getCompletedAt());
                                        response.setAchievedDate(completion.getCompletionDate());
                                        response.setDoneClearedAt(completion.getClearedAt());
                                        return response;
                                })
                                .filter(task -> task.getDoneClearedAt() == null)
                                .toList();

                return java.util.stream.Stream.concat(normalDone.stream(), recurringDone.stream())
                                .sorted(Comparator
                                                .comparing(
                                                                TaskResponse::getCompletedAt,
                                                                Comparator.nullsLast(Comparator.reverseOrder()))
                                                .thenComparing(
                                                                TaskResponse::getTitle,
                                                                Comparator.nullsLast(String::compareToIgnoreCase)))
                                .toList();
        }
        public List<TaskResponse> getHistoryTasks(UUID userId, LocalDate date) {
                Map<UUID, TaskCompletion> completions = completionRepository
                        .findByUserIdAndCompletionDate(userId, date)
                        .stream()
                        .collect(Collectors.toMap(TaskCompletion::getTaskId, c -> c));

                return repository.findByUserIdAndArchivedFalse(userId).stream()
                        .filter(task -> {
                                if (completions.containsKey(task.getId())) {
                                        return true;
                                }

                                // RULE B: It's a normal task and we know it was completed today.
                                if (!task.isRecurring() && task.getStatus() == TaskStatus.COMPLETED) {
                                        return date.equals(task.getAchievedDate());
                                }

                                return false;
                        })
                        .map(task -> {
                                TaskResponse resp = mapper.toResponse(task);

                                if (completions.containsKey(task.getId())) {
                                        TaskCompletion c = completions.get(task.getId());
                                        resp.setStatus(TaskStatus.COMPLETED);
                                        resp.setCompletedAt(c.getCompletedAt());
                                        resp.setAchievedDate(c.getCompletionDate());
                                        resp.setDoneClearedAt(c.getClearedAt());
                                }
                                return resp;
                        })
                        .sorted(Comparator
                                .comparing(TaskResponse::getCompletedAt, Comparator.nullsLast(Comparator.reverseOrder()))
                                .thenComparing(TaskResponse::getTitle, Comparator.nullsLast(String::compareToIgnoreCase)))
                        .toList();
        }
        public List<TaskResponse> getAllActiveTasks(UUID userId) {
                return repository.findByUserIdAndArchivedFalse(userId).stream()
                        .filter(surfacePolicy::shouldAppearInAll)
                        .sorted(sortPolicy.comparator())
                        .map(mapper::toResponse)
                        .toList();
        }
}