package com.lifeos.backend.task.application;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class TaskBffServiceE2ETest extends BaseE2ETest {

    // These now perfectly match your actual system routes!
    private static final String SURFACE_ENDPOINT = "/api/v1/tasks/me/surfaces";
    private static final String OVERVIEW_ENDPOINT = "/api/v1/tasks/me/overview";
    private static final String TASK_ENDPOINT = "/api/v1/tasks";

    @Test
    void bffSurface_shouldNotExposeCustomWeeklyTasksOnUnscheduledDays() throws Exception {
        User user = testDataHelper.createUser();

        // Start date is Wednesday
        LocalDate wednesday = LocalDate.of(2026, 5, 6);
        LocalDate thursday = LocalDate.of(2026, 5, 7);

        // 1. Create a task that ONLY repeats on Wednesdays
        CreateTaskRequest request = new CreateTaskRequest();
        request.setTitle("Architectural Review");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.STANDARD);
        request.setPriority(TaskPriority.HIGH);
        request.setRecurrenceType(TaskRecurrenceType.CUSTOM_WEEKLY);
        request.setRecurrenceStartDate(wednesday);
        request.setRecurrenceDaysOfWeek("WEDNESDAY");

        mockMvc.perform(post(TASK_ENDPOINT)
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk());

        // 2. Query the BFF Surface for Wednesday (The task MUST be here)
        mockMvc.perform(get(SURFACE_ENDPOINT)
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", wednesday.toString())
                        .param("filter", "ALL"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.dueTasks[?(@.title=='Architectural Review')]").exists())
                .andExpect(jsonPath("$.data.todayTasks[?(@.title=='Architectural Review')]").exists());

        // 3. Query the BFF Surface for Thursday (The task MUST NOT be here)
        mockMvc.perform(get(SURFACE_ENDPOINT)
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", thursday.toString())
                        .param("filter", "ALL"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.dueTasks[?(@.title=='Architectural Review')]").doesNotExist())
                .andExpect(jsonPath("$.data.todayTasks[?(@.title=='Architectural Review')]").doesNotExist());
    }

    @Test
    void bffOverview_shouldAlignCurrentTaskAndSectionsWithRecurrenceRules() throws Exception {
        User user = testDataHelper.createUser();

        LocalDate wednesday = LocalDate.of(2026, 5, 6);
        LocalDate thursday = LocalDate.of(2026, 5, 7);

        CreateTaskRequest request = new CreateTaskRequest();
        request.setTitle("Deep Work Session");
        request.setTaskMode(TaskMode.URGENT);
        request.setPriority(TaskPriority.HIGH);
        request.setRecurrenceType(TaskRecurrenceType.CUSTOM_WEEKLY);
        request.setRecurrenceStartDate(wednesday);
        request.setRecurrenceDaysOfWeek("WEDNESDAY");

        mockMvc.perform(post(TASK_ENDPOINT)
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk());

        // Overview on Wednesday should feature this task
        mockMvc.perform(get(OVERVIEW_ENDPOINT)
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", wednesday.toString()))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.currentTask.title").value("Deep Work Session"))
                .andExpect(jsonPath("$.data.todaySections.urgentTasks[?(@.title=='Deep Work Session')]").exists());

        // Overview on Thursday should be completely empty of this task
        mockMvc.perform(get(OVERVIEW_ENDPOINT)
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", thursday.toString()))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.todaySections.urgentTasks[?(@.title=='Deep Work Session')]").doesNotExist());
    }
}