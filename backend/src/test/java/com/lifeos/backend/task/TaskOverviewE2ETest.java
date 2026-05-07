package com.lifeos.backend.task;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TaskOverviewE2ETest extends BaseE2ETest {

    @Test
    void getOverview_shouldReturnCurrentSectionsAndCounts() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");

        mockMvc.perform(get("/api/v1/tasks/me/overview")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.currentTask").exists())
                .andExpect(jsonPath("$.data.currentTask.title").value("Urgent task"))

                .andExpect(jsonPath("$.data.todaySections").exists())
                .andExpect(jsonPath("$.data.todaySections.urgentTasks.length()").value(1))
                .andExpect(jsonPath("$.data.todaySections.progressTasks.length()").value(1))
                .andExpect(jsonPath("$.data.todaySections.dailyTasks.length()").value(1))
                .andExpect(jsonPath("$.data.todaySections.standardTasks.length()").value(0))

                .andExpect(jsonPath("$.data.todayCounts").exists());
    }

    @Test
    void getOverview_shouldPreferUrgentTaskAsCurrentTask() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");
        testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");

        mockMvc.perform(get("/api/v1/tasks/me/overview")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.currentTask.title").value("Urgent task"));
    }

    @Test
    void getOverview_shouldReturnEmptySectionsWhenNoTasksExist() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        mockMvc.perform(get("/api/v1/tasks/me/overview")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.currentTask").doesNotExist())
                .andExpect(jsonPath("$.data.todaySections.urgentTasks.length()").value(0))
                .andExpect(jsonPath("$.data.todaySections.dailyTasks.length()").value(0))
                .andExpect(jsonPath("$.data.todaySections.progressTasks.length()").value(0))
                .andExpect(jsonPath("$.data.todaySections.standardTasks.length()").value(0));
    }

    @Test
    void getOverview_shouldExcludeArchivedTasks() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var archived = testDataHelper.createUrgentTask(user.getId(), date, "Archived urgent");
        testDataHelper.createDailyTask(user.getId(), date, "Visible daily");

        mockMvc.perform(post("/api/v1/tasks/{taskId}/archive", archived.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/tasks/me/overview")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.currentTask.title").value("Visible daily"))
                .andExpect(jsonPath("$.data.todaySections.urgentTasks.length()").value(0))
                .andExpect(jsonPath("$.data.todaySections.dailyTasks.length()").value(1));
    }
}