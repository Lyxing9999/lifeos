package com.lifeos.backend.support;

import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.application.ScheduleCommandService;
import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.application.command.TaskCommandService;
import com.lifeos.backend.task.application.query.TaskQueryService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import com.lifeos.backend.task.domain.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Set;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class TestDataHelper {

    private final UserRepository userRepository;
    private final TaskQueryService taskQueryService;
    private final ScheduleCommandService scheduleCommandService;
    private final TaskCommandService taskCommandService;
    private final TaskRepository taskRepository;
    public User createUser() {
        User user = new User();
        user.setName("Test User");
        user.setEmail("test-" + UUID.randomUUID() + "@example.com");
        user.setTimezone("Asia/Phnom_Penh");
        user.setLocale("en");
        user.setActive(true);
        return userRepository.save(user);
    }
    public TaskInstance createTaskWithoutDueDate(UUID userId, String title) {
        TaskInstance task = new TaskInstance();
        task.setUserId(userId);
        task.setTitle(title);
        task.setStatus(TaskStatus.TODO);
        task.setTaskMode(TaskMode.STANDARD);
        task.setPriority(TaskPriority.MEDIUM);
        task.setArchived(false);
        task.setPaused(false);
        task.setRecurrenceRule(TaskRecurrenceRule.none());

        return taskRepository.save(task);
    }
    public TaskResponse createUrgentTask(UUID userId, LocalDate date, String title) {
        CreateTaskRequest request = new CreateTaskRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Urgent test task");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.URGENT);
        request.setPriority(TaskPriority.HIGH);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(15, 0));
        request.setProgressPercent(null);
        request.setRecurrenceType(TaskRecurrenceType.NONE);
        request.setTags(Set.of("test", "urgent"));
        return taskCommandService.create(request);
    }

    public TaskResponse createProgressTask(UUID userId, LocalDate date, String title, int progressPercent) {
        CreateTaskRequest request = new CreateTaskRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Progress test task");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.PROGRESS);
        request.setPriority(TaskPriority.HIGH);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(20, 0));
        request.setProgressPercent(progressPercent);
        request.setRecurrenceType(TaskRecurrenceType.NONE);
        request.setTags(Set.of("test", "urgent"));
        return taskCommandService.create(request);
    }

    public TaskResponse createDailyTask(UUID userId, LocalDate date, String title) {
        CreateTaskRequest request = new CreateTaskRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Daily recurring task");
        request.setCategory("PERSONAL");
        request.setTaskMode(TaskMode.DAILY);
        request.setPriority(TaskPriority.MEDIUM);
        request.setDueDate(null);
        request.setDueDateTime(null);
        request.setProgressPercent(null);
        request.setRecurrenceType(TaskRecurrenceType.DAILY);
        request.setRecurrenceStartDate(date);
        request.setTags(Set.of("test", "urgent"));
        return taskCommandService.create(request);
    }
    public TaskResponse createTaskWithTags(
            UUID userId,
            LocalDate date,
            String title,
            Set<String> tags
    ) {
        CreateTaskRequest request = new CreateTaskRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Tagged test task");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.STANDARD);
        request.setPriority(TaskPriority.MEDIUM);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(10, 0));
        request.setProgressPercent(null);
        request.setRecurrenceType(TaskRecurrenceType.NONE);
        request.setTags(tags);

        return taskCommandService.create(request);
    }
    public TaskResponse createDailyTaskLinkedToSchedule(
            UUID userId,
            LocalDate date,
            String title,
            UUID scheduleBlockId
    ) {
        CreateTaskRequest request = new CreateTaskRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Daily linked recurring task");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.DAILY);
        request.setPriority(TaskPriority.MEDIUM);
        request.setDueDate(null);
        request.setDueDateTime(null);
        request.setProgressPercent(null);
        request.setRecurrenceType(TaskRecurrenceType.DAILY);
        request.setRecurrenceStartDate(date);
        request.setLinkedScheduleBlockId(scheduleBlockId);
        request.setTags(Set.of("work", "daily"));

        return taskCommandService.create(request);
    }
    public void completeTask(UUID taskId) {
        var task = taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalStateException("Test task not found: " + taskId));

        taskCommandService.complete(task.getUserId(), taskId);
    }

    public void reopenTask(UUID taskId) {
        var task = taskRepository.findById(taskId);
    }
    public ScheduleBlockResponse createOneTimeSchedule(UUID userId, LocalDate date, String title, int startHour, int endHour) {
        return createSchedule(
                userId,
                date,
                title,
                startHour,
                endHour,
                ScheduleBlockType.WORK,
                ScheduleRecurrenceType.NONE,
                null,
                null
        );
    }

    public ScheduleBlockResponse createDailySchedule(UUID userId, LocalDate date, String title, int startHour, int endHour) {
        return createSchedule(
                userId,
                date,
                title,
                startHour,
                endHour,
                ScheduleBlockType.PERSONAL,
                ScheduleRecurrenceType.DAILY,
                null,
                null
        );
    }

    public ScheduleBlockResponse createWeeklySchedule(UUID userId, LocalDate date, String title, int startHour, int endHour) {
        return createSchedule(
                userId,
                date,
                title,
                startHour,
                endHour,
                ScheduleBlockType.STUDY,
                ScheduleRecurrenceType.WEEKLY,
                null,
                null
        );
    }

    public ScheduleBlockResponse createCustomWeeklySchedule(
            UUID userId,
            LocalDate date,
            String title,
            int startHour,
            int endHour,
            String recurrenceDaysOfWeek
    ) {
        return createSchedule(
                userId,
                date,
                title,
                startHour,
                endHour,
                ScheduleBlockType.EXERCISE,
                ScheduleRecurrenceType.CUSTOM_WEEKLY,
                recurrenceDaysOfWeek,
                null
        );
    }

    public ScheduleBlockResponse createMonthlySchedule(UUID userId, LocalDate date, String title, int startHour, int endHour) {
        return createSchedule(
                userId,
                date,
                title,
                startHour,
                endHour,
                ScheduleBlockType.PERSONAL,
                ScheduleRecurrenceType.MONTHLY,
                null,
                null
        );
    }

    public ScheduleBlockResponse createWorkSchedule(UUID userId, LocalDate date, String title, int startHour, int endHour) {
        return createSchedule(
                userId,
                date,
                title,
                startHour,
                endHour,
                ScheduleBlockType.WORK,
                ScheduleRecurrenceType.WEEKLY,
                null,
                null
        );
    }

    public ScheduleBlockResponse createScheduleWithEndDate(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate,
            String title,
            int startHour,
            int endHour,
            ScheduleRecurrenceType recurrenceType
    ) {
        return createSchedule(
                userId,
                startDate,
                title,
                startHour,
                endHour,
                ScheduleBlockType.PERSONAL,
                recurrenceType,
                null,
                endDate
        );
    }
    public TaskResponse createUrgentTaskLinkedToSchedule(
            UUID userId,
            LocalDate date,
            String title,
            UUID scheduleBlockId
    ) {
        CreateTaskRequest request = new CreateTaskRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Urgent linked test task");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.URGENT);
        request.setPriority(TaskPriority.HIGH);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(15, 0));
        request.setProgressPercent(null);
        request.setRecurrenceType(TaskRecurrenceType.NONE);
        request.setLinkedScheduleBlockId(scheduleBlockId);
        request.setTags(Set.of("test", "linked"));

        return taskCommandService.create(request);
    }
    private ScheduleBlockResponse createSchedule(
            UUID userId,
            LocalDate startDate,
            String title,
            int startHour,
            int endHour,
            ScheduleBlockType type,
            ScheduleRecurrenceType recurrenceType,
            String recurrenceDaysOfWeek,
            LocalDate recurrenceEndDate
    ) {
        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setTitle(title);
        request.setDescription(title + " description");
        request.setType(type);
        request.setStartTime(LocalTime.of(startHour, 0));
        request.setEndTime(LocalTime.of(endHour, 0));
        request.setRecurrenceType(recurrenceType);
        request.setRecurrenceStartDate(startDate);
        request.setRecurrenceEndDate(recurrenceEndDate);
        request.setRecurrenceDaysOfWeek(recurrenceDaysOfWeek);

        return scheduleCommandService.create(userId, request);
    }
}