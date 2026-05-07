package com.lifeos.backend.task;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.request.UpdateTaskRequest;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Set;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TaskValidationE2ETest extends BaseE2ETest {

    @Test
    void createTask_shouldFailWhenProgressPercentUsedOnUrgentTask() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        CreateTaskRequest request = new CreateTaskRequest();
        request.setTitle("Invalid urgent task");
        request.setDescription("Should fail");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.URGENT);
        request.setPriority(TaskPriority.HIGH);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(15, 0));
        request.setProgressPercent(50);
        request.setRecurrenceType(TaskRecurrenceType.NONE);
        request.setTags(Set.of("invalid", "urgent"));

        mockMvc.perform(post("/api/v1/tasks")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Progress percent is only allowed for PROGRESS tasks"));
    }

    @Test
    void createTask_shouldFailWhenProgressPercentOutOfRange() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        CreateTaskRequest request = new CreateTaskRequest();
        request.setTitle("Invalid progress task");
        request.setDescription("Should fail");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.PROGRESS);
        request.setPriority(TaskPriority.HIGH);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(15, 0));
        request.setProgressPercent(101);
        request.setRecurrenceType(TaskRecurrenceType.NONE);
        request.setTags(Set.of("invalid", "progress"));

        mockMvc.perform(post("/api/v1/tasks")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Progress percent must be between 0 and 100"));
    }

    @Test
    void createTask_shouldFailWhenRecurringTaskMissingStartDate() throws Exception {
        User user = testDataHelper.createUser();

        CreateTaskRequest request = new CreateTaskRequest();
        request.setTitle("Recurring task without start");
        request.setDescription("Should fail");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.DAILY);
        request.setPriority(TaskPriority.MEDIUM);
        request.setRecurrenceType(TaskRecurrenceType.DAILY);
        request.setTags(Set.of("invalid", "recurrence"));

        mockMvc.perform(post("/api/v1/tasks")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("recurrenceStartDate is required for recurring task"));
    }

    @Test
    void createTask_shouldFailWhenRecurrenceEndBeforeStart() throws Exception {
        User user = testDataHelper.createUser();

        CreateTaskRequest request = new CreateTaskRequest();
        request.setTitle("Recurring task invalid range");
        request.setDescription("Should fail");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.DAILY);
        request.setPriority(TaskPriority.MEDIUM);
        request.setRecurrenceType(TaskRecurrenceType.DAILY);
        request.setRecurrenceStartDate(LocalDate.of(2026, 4, 22));
        request.setRecurrenceEndDate(LocalDate.of(2026, 4, 21));
        request.setTags(Set.of("invalid", "range"));

        mockMvc.perform(post("/api/v1/tasks")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("recurrenceEndDate must be on or after recurrenceStartDate"));
    }

    @Test
    void createTask_shouldFailWhenCustomWeeklyMissingDays() throws Exception {
        User user = testDataHelper.createUser();

        CreateTaskRequest request = new CreateTaskRequest();
        request.setTitle("Custom weekly task invalid");
        request.setDescription("Should fail");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.DAILY);
        request.setPriority(TaskPriority.MEDIUM);
        request.setRecurrenceType(TaskRecurrenceType.CUSTOM_WEEKLY);
        request.setRecurrenceStartDate(LocalDate.of(2026, 4, 22));
        request.setTags(Set.of("invalid", "custom"));

        mockMvc.perform(post("/api/v1/tasks")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY"));
    }

    @Test
    void updateTask_shouldFailWhenProgressPercentAppliedToNonProgressMode() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var task = testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");

        UpdateTaskRequest request = new UpdateTaskRequest();
        request.setProgressPercent(70);

        mockMvc.perform(patch("/api/v1/tasks/{taskId}", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Progress percent is only allowed for PROGRESS tasks"));
    }

    @Test
    void archiveTask_shouldFailWhenTaskNotFound() throws Exception {
        User user = testDataHelper.createUser();

        mockMvc.perform(post("/api/v1/tasks/{taskId}/archive", UUID.randomUUID())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Task not found"));
    }

    @Test
    void restoreTask_shouldFailWhenTaskNotFound() throws Exception {
        User user = testDataHelper.createUser();

        mockMvc.perform(post("/api/v1/tasks/{taskId}/restore", UUID.randomUUID())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Task not found"));
    }

    @Test
    void completeTask_shouldFailWhenTaskNotFound() throws Exception {
        User user = testDataHelper.createUser();

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", UUID.randomUUID())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Task not found"));
    }
}