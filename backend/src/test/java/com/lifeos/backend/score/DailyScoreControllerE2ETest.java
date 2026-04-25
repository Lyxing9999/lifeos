package com.lifeos.backend.score;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class DailyScoreControllerE2ETest extends BaseE2ETest {

    @Test
    void generateScore_shouldReturnFreshScore() throws Exception {
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

        mockMvc.perform(post("/api/v1/score/user/{userId}/generate", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.scoreDate").value("2026-04-22"))
                .andExpect(jsonPath("$.data.completedTasks").value(1))
                .andExpect(jsonPath("$.data.totalTasks").value(3))
                .andExpect(jsonPath("$.data.totalPlannedBlocks").value(4))
                .andExpect(jsonPath("$.data.totalStaySessions").value(0))
                .andExpect(jsonPath("$.data.completionScore").value(33))
                .andExpect(jsonPath("$.data.structureScore").value(80))
                .andExpect(jsonPath("$.data.overallScore").value(57))
                .andExpect(jsonPath("$.data.scoreExplanation").exists());
    }

    @Test
    void getScore_shouldReturnPersistedScore() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var urgent = testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
        testDataHelper.completeTask(urgent.getId());

        mockMvc.perform(post("/api/v1/score/user/{userId}/generate", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/score/user/{userId}/day", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.completedTasks").value(1))
                .andExpect(jsonPath("$.data.totalTasks").value(3))
                .andExpect(jsonPath("$.data.totalPlannedBlocks").value(1));
    }
}