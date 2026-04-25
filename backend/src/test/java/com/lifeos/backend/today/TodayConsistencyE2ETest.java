package com.lifeos.backend.today;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TodayConsistencyE2ETest extends BaseE2ETest {

    @Test
    void today_shouldAlignSummaryScoreAndTimelineCounts() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var urgent = testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");

        testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Wednesday Block", 8, 9);
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
        testDataHelper.createWeeklySchedule(user.getId(), date, "Weekly Wednesday Review", 10, 11);
        testDataHelper.createCustomWeeklySchedule(user.getId(), date, "Custom Wednesday Gym", 18, 19, "WEDNESDAY");

        testDataHelper.completeTask(urgent.getId());

        mockMvc.perform(get("/api/v1/today/{userId}", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.summary.totalTasks").value(3))
                .andExpect(jsonPath("$.data.summary.completedTasks").value(1))
                .andExpect(jsonPath("$.data.summary.totalPlannedBlocks").value(4))

                .andExpect(jsonPath("$.data.score.totalTasks").value(3))
                .andExpect(jsonPath("$.data.score.completedTasks").value(1))
                .andExpect(jsonPath("$.data.score.totalPlannedBlocks").value(4))

                .andExpect(jsonPath("$.data.timeline.summary.totalTasks").value(3))
                .andExpect(jsonPath("$.data.timeline.summary.completedTasks").value(1))
                .andExpect(jsonPath("$.data.timeline.summary.totalPlannedBlocks").value(4));
    }
}