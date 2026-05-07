package com.lifeos.backend.score;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class DailyScoreControllerE2ETest extends BaseE2ETest {

        @Test
        void generateScore_withAuth_shouldReturnFreshScoreForMe() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                var urgent = testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
                testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
                testDataHelper.createDailyTask(user.getId(), date, "Daily task");

                testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Wednesday Block", 8, 9);
                testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
                testDataHelper.createWeeklySchedule(user.getId(), date, "Weekly Wednesday Review", 10, 11);
                testDataHelper.createCustomWeeklySchedule(user.getId(), date, "Custom Wednesday Gym", 18, 19,
                                "WEDNESDAY");

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", urgent.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
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
        void getScore_withAuth_shouldReturnPersistedScoreForMe() throws Exception {
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

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(get("/api/v1/score/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                                .andExpect(jsonPath("$.data.completedTasks").value(1))
                                .andExpect(jsonPath("$.data.totalTasks").value(3))
                                .andExpect(jsonPath("$.data.totalPlannedBlocks").value(1));
        }

        @Test
        void generateScore_withAuthAndNoTasksOrSchedules_shouldReturnZeroScores() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 23);

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                                .andExpect(jsonPath("$.data.completedTasks").value(0))
                                .andExpect(jsonPath("$.data.totalTasks").value(0))
                                .andExpect(jsonPath("$.data.totalPlannedBlocks").value(0))
                                .andExpect(jsonPath("$.data.completionScore").value(0))
                                .andExpect(jsonPath("$.data.structureScore").value(0))
                                .andExpect(jsonPath("$.data.overallScore").value(0));
        }

        @Test
        void generateScore_withAuthAndAllTasksCompleted_shouldReturn100CompletionScore() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 24);

                var t1 = testDataHelper.createUrgentTask(user.getId(), date, "Urgent");
                var t2 = testDataHelper.createProgressTask(user.getId(), date, "Progress", 100);

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", t1.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", t2.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                                .andExpect(jsonPath("$.data.completedTasks").value(2))
                                .andExpect(jsonPath("$.data.totalTasks").value(2))
                                .andExpect(jsonPath("$.data.completionScore").value(100));
        }

        @Test
        void generateScore_withAuthAndAllTasksIncomplete_shouldReturnZeroCompletionScore() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 25);

                testDataHelper.createUrgentTask(user.getId(), date, "Urgent");
                testDataHelper.createProgressTask(user.getId(), date, "Progress", 0);

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                                .andExpect(jsonPath("$.data.completedTasks").value(0))
                                .andExpect(jsonPath("$.data.totalTasks").value(2))
                                .andExpect(jsonPath("$.data.completionScore").value(0));
        }

        @Test
        void generateScore_withoutAuth_shouldReturnUnauthorized() throws Exception {
                mockMvc.perform(post("/api/v1/score/me/generate")
                                .param("date", "2026-04-22"))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void getScore_withoutAuth_shouldReturnUnauthorized() throws Exception {
                mockMvc.perform(get("/api/v1/score/me/day")
                                .param("date", "2026-04-22"))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void deleteScore_withoutAuth_shouldReturnUnauthorized() throws Exception {
                mockMvc.perform(delete("/api/v1/score/me/day")
                                .param("date", "2026-04-22"))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void generateScore_withMissingDate_shouldReturnError() throws Exception {
                User user = testDataHelper.createUser();

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user)))
                                .andExpect(status().is4xxClientError());
        }

        @Test
        void generateScore_multipleDays_shouldReturnCorrectScoresPerDay() throws Exception {
                User user = testDataHelper.createUser();

                LocalDate d1 = LocalDate.of(2026, 4, 26);
                LocalDate d2 = LocalDate.of(2026, 4, 27);

                testDataHelper.createUrgentTask(user.getId(), d1, "Urgent D1");
                testDataHelper.createUrgentTask(user.getId(), d2, "Urgent D2");

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", d1.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.data.scoreDate").value(d1.toString()));

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", d2.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.data.scoreDate").value(d2.toString()));
        }

        @Test
        void generateScore_idempotency_shouldReturnSameScoreOnRepeat() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 28);

                testDataHelper.createUrgentTask(user.getId(), date, "Urgent");

                var result1 = mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andReturn();

                var result2 = mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andReturn();

                ObjectMapper mapper = new ObjectMapper();

                JsonNode data1 = mapper.readTree(result1.getResponse().getContentAsString()).get("data");
                JsonNode data2 = mapper.readTree(result2.getResponse().getContentAsString()).get("data");

                assert data1.get("completionScore").asInt() == data2.get("completionScore").asInt();
                assert data1.get("structureScore").asInt() == data2.get("structureScore").asInt();
                assert data1.get("overallScore").asInt() == data2.get("overallScore").asInt();
                assert data1.get("completedTasks").asInt() == data2.get("completedTasks").asInt();
                assert data1.get("totalTasks").asInt() == data2.get("totalTasks").asInt();
                assert data1.get("totalPlannedBlocks").asInt() == data2.get("totalPlannedBlocks").asInt();
                assert data1.get("totalStaySessions").asInt() == data2.get("totalStaySessions").asInt();
                assert data1.get("scoreDate").asText().equals(data2.get("scoreDate").asText());
                assert data1.get("scoreExplanation").asText().equals(data2.get("scoreExplanation").asText());
        }

        @Test
        void deleteScore_withAuth_shouldDeletePersistedScoreForMe() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 29);

                testDataHelper.createUrgentTask(user.getId(), date, "Urgent");

                mockMvc.perform(post("/api/v1/score/me/generate")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(delete("/api/v1/score/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true));

                mockMvc.perform(get("/api/v1/score/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isNotFound());
        }

        @Test
        void deprecatedScorePath_shouldIgnorePathUserIdAndUseAuthenticatedUser() throws Exception {
                User realUser = testDataHelper.createUser();
                User otherUser = testDataHelper.createUser();

                LocalDate date = LocalDate.of(2026, 4, 30);

                testDataHelper.createUrgentTask(realUser.getId(), date, "Real user task");
                testDataHelper.createUrgentTask(otherUser.getId(), date, "Other user task");

                mockMvc.perform(post("/api/v1/score/user/{userId}/generate", otherUser.getId())
                                .header("Authorization", authTestHelper.bearer(realUser))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(realUser.getId().toString()))
                                .andExpect(jsonPath("$.data.totalTasks").value(1));
        }
}