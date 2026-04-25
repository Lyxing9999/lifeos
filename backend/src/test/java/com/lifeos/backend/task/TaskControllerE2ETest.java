package com.lifeos.backend.task;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.domain.TaskMode;
import com.lifeos.backend.task.domain.TaskPriority;
import com.lifeos.backend.task.domain.TaskRecurrenceType;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TaskControllerE2ETest extends BaseE2ETest {

    @Test
    void createTask_shouldReturnCreatedTask() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        CreateTaskRequest request = new CreateTaskRequest();
        request.setUserId(user.getId());
        request.setTitle("Fix DTO mismatch");
        request.setDescription("Task create E2E");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.URGENT);
        request.setPriority(TaskPriority.HIGH);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(15, 0));
        request.setProgressPercent(null);
        request.setRecurrenceType(TaskRecurrenceType.NONE);
        request.setTags(Set.of("test", "urgent"));

        mockMvc.perform(post("/api/v1/tasks")
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.title").value("Fix DTO mismatch"))
                .andExpect(jsonPath("$.data.taskMode").value("URGENT"))
                .andExpect(jsonPath("$.data.priority").value("HIGH"))
                .andExpect(jsonPath("$.data.dueDate").value("2026-04-22"));
    }

    @Test
    void getTasksForDay_shouldReturnRelevantTasks() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");

        mockMvc.perform(get("/api/v1/tasks/user/{userId}/day", user.getId())
                        .param("date", date.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(3));
    }

    @Test
    void completeTask_shouldMarkTaskCompleted() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var task = testDataHelper.createUrgentTask(user.getId(), date, "Complete me");

        mockMvc.perform(patch("/api/v1/tasks/{taskId}", task.getId())
                        .contentType(json)
                        .content("""
                        {
                          "status": "COMPLETED"
                        }
                        """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"));
    }
}