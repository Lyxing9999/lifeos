package com.lifeos.backend.summary;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class DailySummaryControllerE2ETest extends BaseE2ETest {

        @Test
        void generateSummary_withAuth_shouldReturnFreshSummaryForMe() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                var urgent = testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
                testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
                testDataHelper.createDailyTask(user.getId(), date, "Daily task");

                testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Wednesday Block", 8, 9);
                testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
                testDataHelper.createWeeklySchedule(user.getId(), date, "Weekly Wednesday Review", 10, 11);
                testDataHelper.createCustomWeeklySchedule(
                                user.getId(),
                                date,
                                "Custom Wednesday Gym",
                                18,
                                19,
                                "WEDNESDAY");

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", urgent.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(post("/api/v1/summaries/daily/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                                .andExpect(jsonPath("$.data.summaryDate").value("2026-04-22"))
                                .andExpect(jsonPath("$.data.completedTasks").value(1))
                                .andExpect(jsonPath("$.data.totalTasks").value(3))
                                .andExpect(jsonPath("$.data.totalPlannedBlocks").value(4))
                                .andExpect(jsonPath("$.data.totalStaySessions").value(0))
                                .andExpect(jsonPath("$.data.summaryText").exists())
                                .andExpect(jsonPath("$.data.scoreExplanationText").exists())
                                .andExpect(jsonPath("$.data.optionalInsight").exists());
        }

        @Test
        void getSummary_withAuth_shouldReturnPersistedSummaryForMe() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                var urgent = testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
                testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
                testDataHelper.createDailyTask(user.getId(), date, "Daily task");
                testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", urgent.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(post("/api/v1/summaries/daily/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(get("/api/v1/summaries/daily/me")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                                .andExpect(jsonPath("$.data.summaryDate").value("2026-04-22"))
                                .andExpect(jsonPath("$.data.completedTasks").value(1))
                                .andExpect(jsonPath("$.data.totalTasks").value(3))
                                .andExpect(jsonPath("$.data.totalPlannedBlocks").value(1));
        }

        @Test
        void deleteSummary_withAuth_shouldDeletePersistedSummaryForMe() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 23);

                testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");

                mockMvc.perform(post("/api/v1/summaries/daily/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(delete("/api/v1/summaries/daily/me")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true));

                mockMvc.perform(get("/api/v1/summaries/daily/me")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isNotFound());
        }

        @Test
        void generateSummary_withNoTasksOrSchedules_shouldReturnEmptyDaySummary() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 24);

                mockMvc.perform(post("/api/v1/summaries/daily/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                                .andExpect(jsonPath("$.data.summaryDate").value("2026-04-24"))
                                .andExpect(jsonPath("$.data.totalTasks").value(0))
                                .andExpect(jsonPath("$.data.completedTasks").value(0))
                                .andExpect(jsonPath("$.data.totalPlannedBlocks").value(0))
                                .andExpect(jsonPath("$.data.totalStaySessions").value(0))
                                .andExpect(jsonPath("$.data.summaryText").exists());
        }

        @Test
        void generateSummary_multipleDays_shouldReturnCorrectSummaryDatePerDay() throws Exception {
                User user = testDataHelper.createUser();

                LocalDate dayOne = LocalDate.of(2026, 4, 26);
                LocalDate dayTwo = LocalDate.of(2026, 4, 27);

                testDataHelper.createUrgentTask(user.getId(), dayOne, "Day one task");
                testDataHelper.createUrgentTask(user.getId(), dayTwo, "Day two task");

                mockMvc.perform(post("/api/v1/summaries/daily/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", dayOne.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.summaryDate").value(dayOne.toString()))
                                .andExpect(jsonPath("$.data.totalTasks").isNumber());

                mockMvc.perform(post("/api/v1/summaries/daily/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", dayTwo.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.summaryDate").value(dayTwo.toString()))
                                .andExpect(jsonPath("$.data.totalTasks").isNumber());
        }

        @Test
        void generateSummary_withoutAuth_shouldReturnUnauthorized() throws Exception {
                mockMvc.perform(post("/api/v1/summaries/daily/me/generate")
                                .param("date", "2026-04-22"))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void getSummary_withoutAuth_shouldReturnUnauthorized() throws Exception {
                mockMvc.perform(get("/api/v1/summaries/daily/me")
                                .param("date", "2026-04-22"))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void deleteSummary_withoutAuth_shouldReturnUnauthorized() throws Exception {
                mockMvc.perform(delete("/api/v1/summaries/daily/me")
                                .param("date", "2026-04-22"))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void generateSummary_withMissingDate_shouldReturnBadRequest() throws Exception {
                User user = testDataHelper.createUser();

                mockMvc.perform(post("/api/v1/summaries/daily/me/generate")
                                .header("Authorization", authTestHelper.bearer(user)))
                                .andExpect(status().is4xxClientError());
        }

        @Test
        void deprecatedSummaryPath_shouldIgnorePathUserIdAndUseAuthenticatedUser() throws Exception {
                User realUser = testDataHelper.createUser();
                User otherUser = testDataHelper.createUser();

                LocalDate date = LocalDate.of(2026, 4, 28);

                testDataHelper.createUrgentTask(realUser.getId(), date, "Real user task");
                testDataHelper.createUrgentTask(otherUser.getId(), date, "Other user task");

                mockMvc.perform(post("/api/v1/summaries/daily/generate/{userId}", otherUser.getId())
                                .header("Authorization", authTestHelper.bearer(realUser))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(realUser.getId().toString()))
                                .andExpect(jsonPath("$.data.totalTasks").value(1));
        }
}