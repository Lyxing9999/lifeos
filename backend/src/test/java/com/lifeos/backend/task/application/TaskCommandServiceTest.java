package com.lifeos.backend.task.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.ScheduleQueryService;
import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.TaskCompletion;
import com.lifeos.backend.task.domain.TaskCompletionRepository;
import com.lifeos.backend.task.domain.TaskRepository;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.task.domain.policy.TaskValidationPolicy;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import com.lifeos.backend.task.infrastructure.TaskMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TaskCommandServiceTest {

    @Mock
    private TaskRepository repository;

    @Mock
    private TaskCompletionRepository completionRepository;

    @Mock
    private TaskMapper mapper;

    @Mock
    private TaskValidationPolicy validationPolicy;

    @Mock
    private UserTimeService userTimeService;

    @Mock
    private ScheduleQueryService scheduleQueryService;

    @InjectMocks
    private TaskCommandService service;

    @Test
    void clearDoneForDay_clearsNormalCompletedTaskByAchievedDate() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 1);

        Task task = normalCompletedTask(userId, "Inbox win");
        task.setDueDate(null);
        task.setDueDateTime(null);
        task.setAchievedDate(date);

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(task));

        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of());

        service.clearDoneForDay(userId, date);

        assertThat(task.getDoneClearedAt()).isNotNull();

        verify(repository).findByUserIdAndArchivedFalse(userId);
        verify(repository).saveAll(List.of(task));
        verify(completionRepository).findByUserIdAndCompletionDate(userId, date);
        verify(completionRepository, never()).saveAll(anyList());
    }

    @Test
    void clearDoneForDay_clearsNormalCompletedTaskByDueDateWhenNoAchievedDate() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 1);

        Task task = normalCompletedTask(userId, "Pay rent");
        task.setAchievedDate(null);
        task.setDueDate(date);

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(task));

        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of());

        service.clearDoneForDay(userId, date);

        assertThat(task.getDoneClearedAt()).isNotNull();

        verify(repository).saveAll(List.of(task));
        verify(completionRepository, never()).saveAll(anyList());
    }

    @Test
    void clearDoneForDay_clearsNormalCompletedTaskByDueDateTimeDayWhenNoAchievedDate() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 1);

        Task task = normalCompletedTask(userId, "Submit report");
        task.setAchievedDate(null);
        task.setDueDateTime(LocalDateTime.of(2026, 5, 1, 14, 30));

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(task));

        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of());

        service.clearDoneForDay(userId, date);

        assertThat(task.getDoneClearedAt()).isNotNull();

        verify(repository).saveAll(List.of(task));
        verify(completionRepository, never()).saveAll(anyList());
    }

    @Test
    void clearDoneForDay_prefersAchievedDateOverDueDate() {
        UUID userId = UUID.randomUUID();

        LocalDate achievedDate = LocalDate.of(2026, 5, 1);
        LocalDate dueDate = LocalDate.of(2026, 5, 10);

        Task task = normalCompletedTask(userId, "Finish early");
        task.setAchievedDate(achievedDate);
        task.setDueDate(dueDate);

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(task));

        when(completionRepository.findByUserIdAndCompletionDate(userId, achievedDate))
                .thenReturn(List.of());

        service.clearDoneForDay(userId, achievedDate);

        assertThat(task.getDoneClearedAt()).isNotNull();

        verify(repository).saveAll(List.of(task));
    }

    @Test
    void clearDoneForDay_doesNotClearNormalCompletedTaskFromDifferentAchievedDate() {
        UUID userId = UUID.randomUUID();
        LocalDate selectedDate = LocalDate.of(2026, 5, 1);

        Task task = normalCompletedTask(userId, "Pay rent");
        task.setAchievedDate(LocalDate.of(2026, 5, 2));
        task.setDueDate(selectedDate);

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(task));

        when(completionRepository.findByUserIdAndCompletionDate(userId, selectedDate))
                .thenReturn(List.of());

        service.clearDoneForDay(userId, selectedDate);

        assertThat(task.getDoneClearedAt()).isNull();

        verify(repository, never()).saveAll(anyList());
        verify(completionRepository, never()).saveAll(anyList());
    }

    @Test
    void clearDoneForDay_doesNotClearActiveNormalTask() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 1);

        Task task = normalTask(userId, "Buy shoes");
        task.setStatus(TaskStatus.TODO);
        task.setDueDate(date);

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(task));

        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of());

        service.clearDoneForDay(userId, date);

        assertThat(task.getDoneClearedAt()).isNull();

        verify(repository, never()).saveAll(anyList());
        verify(completionRepository, never()).saveAll(anyList());
    }

    @Test
    void clearDoneForDay_doesNotClearOldNoDateCompletedTaskWithoutAchievedDate() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 1);

        Task task = normalCompletedTask(userId, "Old inbox task");
        task.setDueDate(null);
        task.setDueDateTime(null);
        task.setAchievedDate(null);

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(task));

        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of());

        service.clearDoneForDay(userId, date);

        assertThat(task.getDoneClearedAt()).isNull();

        verify(repository, never()).saveAll(anyList());
        verify(completionRepository, never()).saveAll(anyList());
    }

    @Test
    void clearDoneForDay_clearsRecurringCompletionsForThatDay() {
        UUID userId = UUID.randomUUID();
        UUID taskId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 1);

        TaskCompletion completion = new TaskCompletion();
        completion.setUserId(userId);
        completion.setTaskId(taskId);
        completion.setCompletionDate(date);
        completion.setCompletedAt(Instant.now());

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of());

        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of(completion));

        service.clearDoneForDay(userId, date);

        assertThat(completion.getClearedAt()).isNotNull();

        verify(repository).findByUserIdAndArchivedFalse(userId);
        verify(repository, never()).saveAll(anyList());
        verify(completionRepository).findByUserIdAndCompletionDate(userId, date);
        verify(completionRepository).saveAll(List.of(completion));
    }

    @Test
    void clearDoneForDay_clearsNormalAndRecurringDoneForSameDay() {
        UUID userId = UUID.randomUUID();
        UUID recurringTaskId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 1);

        Task normalTask = normalCompletedTask(userId, "Pay rent");
        normalTask.setAchievedDate(date);

        TaskCompletion recurringCompletion = new TaskCompletion();
        recurringCompletion.setUserId(userId);
        recurringCompletion.setTaskId(recurringTaskId);
        recurringCompletion.setCompletionDate(date);
        recurringCompletion.setCompletedAt(Instant.now());

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(normalTask));

        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of(recurringCompletion));

        service.clearDoneForDay(userId, date);

        assertThat(normalTask.getDoneClearedAt()).isNotNull();
        assertThat(recurringCompletion.getClearedAt()).isNotNull();

        verify(repository).saveAll(List.of(normalTask));
        verify(completionRepository).saveAll(List.of(recurringCompletion));
    }

    @Test
    void clearDoneForDay_usesUserTimezoneWhenDateIsNull() {
        UUID userId = UUID.randomUUID();
        ZoneId zoneId = ZoneId.of("Asia/Phnom_Penh");

        LocalDate todayInUserZone = Instant.now()
                .atZone(zoneId)
                .toLocalDate();

        Task task = normalCompletedTask(userId, "Today task");
        task.setAchievedDate(todayInUserZone);

        when(userTimeService.getUserZoneId(userId))
                .thenReturn(zoneId);

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of(task));

        when(completionRepository.findByUserIdAndCompletionDate(
                userId,
                todayInUserZone
        )).thenReturn(List.of());

        service.clearDoneForDay(userId, null);

        assertThat(task.getDoneClearedAt()).isNotNull();

        verify(userTimeService).getUserZoneId(userId);
        verify(repository).findByUserIdAndArchivedFalse(userId);
        verify(repository).saveAll(List.of(task));
        verify(completionRepository).findByUserIdAndCompletionDate(
                userId,
                todayInUserZone
        );
    }

    @Test
    void clearDoneForDay_doesNothingWhenNothingMatches() {
        UUID userId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 5, 1);

        when(repository.findByUserIdAndArchivedFalse(userId))
                .thenReturn(List.of());

        when(completionRepository.findByUserIdAndCompletionDate(userId, date))
                .thenReturn(List.of());

        service.clearDoneForDay(userId, date);

        verify(repository).findByUserIdAndArchivedFalse(userId);
        verify(repository, never()).saveAll(anyList());
        verify(completionRepository).findByUserIdAndCompletionDate(userId, date);
        verify(completionRepository, never()).saveAll(anyList());
    }

    @Test
    void pause_pausesTaskWithoutChangingCompletionState() {
        UUID userId = UUID.randomUUID();
        UUID taskId = UUID.randomUUID();

        Task task = normalTask(userId, "Daily workout");
        task.setId(taskId);

        when(repository.findById(taskId))
                .thenReturn(Optional.of(task));

        when(repository.save(task))
                .thenReturn(task);

        service.pause(userId, taskId, null);

        assertThat(task.getPaused()).isTrue();
        assertThat(task.getPausedAt()).isNotNull();
        assertThat(task.getPauseUntil()).isNull();

        verify(repository).save(task);
    }

    @Test
    void pauseUntil_pausesTaskUntilDate() {
        UUID userId = UUID.randomUUID();
        UUID taskId = UUID.randomUUID();
        LocalDate until = LocalDate.of(2026, 5, 10);

        Task task = normalTask(userId, "School routine");
        task.setId(taskId);

        when(repository.findById(taskId))
                .thenReturn(Optional.of(task));

        when(repository.save(task))
                .thenReturn(task);

        service.pause(userId, taskId, until);

        assertThat(task.getPaused()).isTrue();
        assertThat(task.getPausedAt()).isNotNull();
        assertThat(task.getPauseUntil()).isEqualTo(until);

        verify(repository).save(task);
    }

    @Test
    void resume_resumesPausedTask() {
        UUID userId = UUID.randomUUID();
        UUID taskId = UUID.randomUUID();

        Task task = normalTask(userId, "Daily workout");
        task.setId(taskId);
        task.pauseUntil(LocalDate.of(2026, 5, 10));

        when(repository.findById(taskId))
                .thenReturn(Optional.of(task));

        when(repository.save(task))
                .thenReturn(task);

        service.resume(userId, taskId);

        assertThat(task.getPaused()).isFalse();
        assertThat(task.getPausedAt()).isNull();
        assertThat(task.getPauseUntil()).isNull();

        verify(repository).save(task);
    }

    private Task normalCompletedTask(UUID userId, String title) {
        Task task = normalTask(userId, title);
        task.setStatus(TaskStatus.COMPLETED);
        task.setCompletedAt(Instant.now());
        return task;
    }

    private Task normalTask(UUID userId, String title) {
        Task task = new Task();
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

    @SuppressWarnings("unused")
    private Task recurringTask(UUID userId, String title) {
        Task task = normalTask(userId, title);
        task.setRecurrenceRule(new TaskRecurrenceRule(
                TaskRecurrenceType.DAILY,
                LocalDate.of(2026, 5, 1),
                null,
                null
        ));
        return task;
    }
}