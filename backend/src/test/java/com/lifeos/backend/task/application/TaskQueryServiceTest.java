package com.lifeos.backend.task.application;

import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.application.query.TaskQueryService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.TaskCompletionRepository;
import com.lifeos.backend.task.domain.TaskRepository;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.task.domain.policy.TaskSortPolicy;
import com.lifeos.backend.task.domain.policy.TaskSurfacePolicy;
import com.lifeos.backend.task.domain.service.TaskRecurrenceResolver;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import com.lifeos.backend.task.infrastructure.TaskMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.lenient;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TaskQueryServiceTest {

    @Mock
    private TaskRepository repository;

    @Mock
    private TaskMapper mapper;

    @Mock
    private TaskRecurrenceResolver recurrenceResolver;

    @Mock
    private TaskSortPolicy sortPolicy;

    @Mock
    private TaskCompletionRepository completionRepository;

    private TaskQueryService service;

    private TaskQueryService service() {
        TaskSurfacePolicy surfacePolicy = new TaskSurfacePolicy(recurrenceResolver);

        return new TaskQueryService(
                repository,
                mapper,
                recurrenceResolver,
                sortPolicy,
                completionRepository,
                surfacePolicy
        );
    }

    @Test
    void dueTasks_includeActiveDueTodayTask() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 3);

        TaskInstance task = activeTask(userId, "Pay rent");
        task.setDueDate(date);

        mockTaskList(userId, List.of(task));

        List<TaskResponse> result = service().getDueTasks(userId, date);

        assertThat(result).extracting(TaskResponse::getTitle)
                .containsExactly("Pay rent");
    }

    @Test
    void dueTasks_includeOverdueActiveTask() {
        UUID userId = UUID.randomUUID();
        LocalDate selectedDate = LocalDate.of(2026, 5, 3);

        TaskInstance task = activeTask(userId, "Pay rent");
        task.setDueDate(LocalDate.of(2026, 5, 1));

        mockTaskList(userId, List.of(task));

        List<TaskResponse> result = service().getDueTasks(userId, selectedDate);

        assertThat(result).extracting(TaskResponse::getTitle)
                .containsExactly("Pay rent");
    }

    @Test
    void dueTasks_excludeCompletedTask() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 3);

        TaskInstance task = activeTask(userId, "Done task");
        task.setDueDate(date);
        task.setStatus(TaskStatus.COMPLETED);

        mockTaskList(userId, List.of(task));

        List<TaskResponse> result = service().getDueTasks(userId, date);

        assertThat(result).isEmpty();
    }

    @Test
    void dueTasks_excludePlainUrgentTaskWithoutDueScheduleOrRecurrence() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 3);

        TaskInstance task = activeTask(userId, "Urgent inbox");
        task.setTaskMode(TaskMode.URGENT);

        mockTaskList(userId, List.of(task));
        lenient().when(recurrenceResolver.isRelevantOn(task, date)).thenReturn(false);

        List<TaskResponse> result = service().getDueTasks(userId, date);

        assertThat(result).isEmpty();
    }

    @Test
    void inboxTasks_includePlainActiveTask() {
        UUID userId = UUID.randomUUID();

        TaskInstance task = activeTask(userId, "Buy shoes");

        mockTaskList(userId, List.of(task));

        List<TaskResponse> result = service().getInboxTasks(userId);

        assertThat(result).extracting(TaskResponse::getTitle)
                .containsExactly("Buy shoes");
    }

    @Test
    void inboxTasks_excludeTaskWithDueDate() {
        UUID userId = UUID.randomUUID();

        TaskInstance task = activeTask(userId, "Pay rent");
        task.setDueDate(LocalDate.of(2026, 5, 3));

        mockTaskList(userId, List.of(task));

        List<TaskResponse> result = service().getInboxTasks(userId);

        assertThat(result).isEmpty();
    }

    @Test
    void inboxTasks_excludeRecurringTask() {
        UUID userId = UUID.randomUUID();

        TaskInstance task = activeTask(userId, "Daily workout");
        task.setRecurrenceRule(new TaskRecurrenceRule(
                TaskRecurrenceType.DAILY,
                LocalDate.of(2026, 5, 1),
                null,
                null
        ));

        mockTaskList(userId, List.of(task));

        List<TaskResponse> result = service().getInboxTasks(userId);

        assertThat(result).isEmpty();
    }

    @Test
    void doneTasks_excludeDoneClearedTask() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 3);

        TaskInstance task = activeTask(userId, "Done task");
        task.setStatus(TaskStatus.COMPLETED);
        task.setCompletedAt(Instant.now());
        task.setAchievedDate(date);
        task.clearFromDone();

        mockTaskList(userId, List.of(task));
        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of());

        List<TaskResponse> result = service().getDoneTasks(userId, date);

        assertThat(result).isEmpty();
    }

    @Test
    void historyTasks_includeDoneClearedTask() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 3);

        TaskInstance task = activeTask(userId, "Done task");
        task.setStatus(TaskStatus.COMPLETED);
        task.setCompletedAt(Instant.now());
        task.setAchievedDate(date);
        task.clearFromDone();

        mockTaskList(userId, List.of(task));
        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of());

        List<TaskResponse> result = service().getCompletedHistoryForDay(userId, date);

        assertThat(result).extracting(TaskResponse::getTitle)
                .containsExactly("Done task");
    }

    @Test
    void allTasks_excludeCompletedAndArchived_butIncludePaused() {
        UUID userId = UUID.randomUUID();

        TaskInstance active = activeTask(userId, "Active");

        TaskInstance done = activeTask(userId, "Done");
        done.setStatus(TaskStatus.COMPLETED);

        TaskInstance paused = activeTask(userId, "Paused");
        paused.pause();

        TaskInstance archived = activeTask(userId, "Archived");
        archived.setArchived(true);

        mockTaskList(userId, List.of(active, done, paused, archived));

        List<TaskResponse> result = service().getAllActiveTasks(userId);

        assertThat(result).extracting(TaskResponse::getTitle)
                .containsExactlyInAnyOrder("Active", "Paused");
    }

    private void mockTaskList(UUID userId, List<TaskInstance> tasks) {
        when(repository.findByUserIdAndArchivedFalse(userId)).thenReturn(tasks);
        lenient().when(sortPolicy.comparator())
                .thenReturn(Comparator.comparing(TaskInstance::getTitle));
        for (TaskInstance task : tasks) {
            lenient().when(mapper.toResponse(task)).thenReturn(toResponse(task));
        }
    }
    private TaskInstance activeTask(UUID userId, String title) {
        TaskInstance task = new TaskInstance();
        task.setId(UUID.randomUUID());
        task.setUserId(userId);
        task.setTitle(title);
        task.setStatus(TaskStatus.TODO);
        task.setTaskMode(TaskMode.STANDARD);
        task.setPriority(TaskPriority.MEDIUM);
        task.setArchived(false);
        task.setPaused(false);
        task.setRecurrenceRule(TaskRecurrenceRule.none());
        return task;
    }

    private TaskResponse toResponse(TaskInstance task) {
        return TaskResponse.builder()
                .id(task.getId())
                .userId(task.getUserId())
                .title(task.getTitle())
                .status(task.getStatus())
                .taskMode(task.getTaskMode())
                .priority(task.getPriority())
                .dueDate(task.getDueDate())
                .dueDateTime(task.getDueDateTime())
                .completedAt(task.getCompletedAt())
                .achievedDate(task.getAchievedDate())
                .doneClearedAt(task.getDoneClearedAt())
                .archived(task.getArchived())
                .paused(task.getPaused())
                .recurrenceType(task.getRecurrenceRule() != null
                        ? task.getRecurrenceRule().getType()
                        : TaskRecurrenceType.NONE)
                .linkedScheduleBlockId(task.getLinkedScheduleBlockId())
                .tags(List.of())
                .build();
    }
}