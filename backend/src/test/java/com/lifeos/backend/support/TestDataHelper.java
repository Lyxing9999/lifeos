package com.lifeos.backend.support;

import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.application.ScheduleService;
import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.application.TaskService;
import com.lifeos.backend.task.domain.TaskMode;
import com.lifeos.backend.task.domain.TaskPriority;
import com.lifeos.backend.task.domain.TaskRecurrenceType;
import com.lifeos.backend.task.domain.TaskStatus;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import java.util.Arrays;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class TestDataHelper {

    private final UserRepository userRepository;
    private final TaskService taskService;
    private final ScheduleService scheduleService;

    public User createUser() {
        User user = new User();
        user.setName("Test User");
        user.setEmail("test-" + UUID.randomUUID() + "@example.com");
        user.setTimezone("Asia/Phnom_Penh");
        user.setLocale("en");
        user.setActive(true);
        return userRepository.save(user);
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
        return taskService.create(request);
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
        return taskService.create(request);
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
        return taskService.create(request);
    }

    public void completeTask(UUID taskId) {

        taskService.complete(taskId);

    }

    public void createOneTimeSchedule(UUID userId, LocalDate date, String title, int startHour, int endHour) {
        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("One-time schedule");
        request.setType(ScheduleBlockType.WORK);
        request.setStartTime(LocalTime.of(startHour, 0));
        request.setEndTime(LocalTime.of(endHour, 0));
        request.setRecurrenceType(ScheduleRecurrenceType.NONE);
        request.setRecurrenceStartDate(date);
        request.setRecurrenceEndDate(null);
        request.setRecurrenceDaysOfWeek(null);
        scheduleService.create(request);
    }

    public void createDailySchedule(UUID userId, LocalDate date, String title, int startHour, int endHour) {
        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Daily schedule");
        request.setType(ScheduleBlockType.PERSONAL);
        request.setStartTime(LocalTime.of(startHour, 0));
        request.setEndTime(LocalTime.of(endHour, 0));
        request.setRecurrenceType(ScheduleRecurrenceType.DAILY);
        request.setRecurrenceStartDate(date);
        request.setRecurrenceEndDate(null);
        request.setRecurrenceDaysOfWeek(null);
        scheduleService.create(request);
    }

    public void createWeeklySchedule(UUID userId, LocalDate date, String title, int startHour, int endHour) {
        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Weekly schedule");
        request.setType(ScheduleBlockType.STUDY);
        request.setStartTime(LocalTime.of(startHour, 0));
        request.setEndTime(LocalTime.of(endHour, 0));
        request.setRecurrenceType(ScheduleRecurrenceType.WEEKLY);
        request.setRecurrenceStartDate(date);
        request.setRecurrenceEndDate(null);
        request.setRecurrenceDaysOfWeek(null);
        scheduleService.create(request);
    }

    public void createCustomWeeklySchedule(
            UUID userId,
            LocalDate date,
            String title,
            int startHour,
            int endHour,
            String recurrenceDaysOfWeek
    ) {
        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setUserId(userId);
        request.setTitle(title);
        request.setDescription("Custom weekly schedule");
        request.setType(ScheduleBlockType.EXERCISE);
        request.setStartTime(LocalTime.of(startHour, 0));
        request.setEndTime(LocalTime.of(endHour, 0));
        request.setRecurrenceType(ScheduleRecurrenceType.CUSTOM_WEEKLY);
        request.setRecurrenceStartDate(date);
        request.setRecurrenceEndDate(null);
        request.setRecurrenceDaysOfWeek(recurrenceDaysOfWeek);
        scheduleService.create(request);
    }





}