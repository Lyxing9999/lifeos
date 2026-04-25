package com.lifeos.backend.task;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TaskOverviewE2ETest extends BaseE2ETest {

    @Test
    void getOverview_shouldReturnCurrentAndSections() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");

        mockMvc.perform(get("/api/v1/tasks/user/{userId}/overview", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.currentTask").exists())
                .andExpect(jsonPath("$.data.todaySections").exists())
                .andExpect(jsonPath("$.data.todaySections.urgentTasks").isArray())
                .andExpect(jsonPath("$.data.todaySections.dailyTasks").isArray())
                .andExpect(jsonPath("$.data.todaySections.progressTasks").isArray())
                .andExpect(jsonPath("$.data.todayCounts").exists());
    }
}