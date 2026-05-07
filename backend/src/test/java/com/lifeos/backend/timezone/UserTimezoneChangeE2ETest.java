package com.lifeos.backend.timezone;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.api.request.UpdateUserProfileRequest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * SENIOR ARCHITECTURE TEST: Timezone Stability
 * Ensures that changing a user's location does NOT shift their plan.
 * A task on the 22nd stays on the 22nd.
 */
class UserTimezoneChangeE2ETest extends BaseE2ETest {

        @Test
        void taskDueDateTime_shouldStayOnOriginalLocalDayAfterTimezoneChangesFromPhnomPenhToBangkok() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate khDate = LocalDate.of(2026, 4, 22);

                testDataHelper.createUrgentTask(user.getId(), khDate, "KH evening task");

                updateMyTimezone(user, "Asia/Bangkok");

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", "2026-04-22")
                                .param("filter", "ALL"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data[0].dueDate").value("2026-04-22"));
        }

        @Test
        void taskDueDateTime_shouldStayOnOriginalLocalDayAfterTimezoneChangesFromPhnomPenhToNewYork() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate khDate = LocalDate.of(2026, 4, 22);

                testDataHelper.createUrgentTask(user.getId(), khDate, "Do not shift me");

                // Act: Shift half-way around the world
                updateMyTimezone(user, "America/New_York");

                // Assert: Task is still on the 22nd
                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", "2026-04-22")
                                .param("filter", "ALL"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data[0].title").value("Do not shift me"))
                        .andExpect(jsonPath("$.data[0].dueDate").value("2026-04-22"));

                // Assert: Task is NOT on the 21st (No backwards leak)
                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", "2026-04-21")
                                .param("filter", "ALL"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.length()").value(0));
        }

        @Test
        void scheduleOccurrence_shouldRemainStableAcrossTimezoneChangeFromPhnomPenhToNewYork() throws Exception {
                User user = testDataHelper.createUser();
                String auth = authTestHelper.bearer(user);
                LocalDate localDate = LocalDate.of(2026, 4, 22);

                testDataHelper.createOneTimeSchedule(user.getId(), localDate, "Morning Block", 8, 9);

                updateMyTimezone(user, "America/New_York");

                // Verify Surface (Blueprint)
                mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                                .header("Authorization", auth)
                                .param("date", localDate.toString()))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.activeBlocks[0].startTime").value("08:00:00"));

                // Verify it dynamically moves to history if we check the next day
                mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                                .header("Authorization", auth)
                                .param("date", "2026-04-23"))
                        .andExpect(jsonPath("$.data.activeBlocks.length()").value(0))
                        .andExpect(jsonPath("$.data.historyBlocks.length()").value(1));
        }

        @Test
        void today_shouldUseRequestedDateWithoutShiftingTasksOrSchedulesAfterTimezoneChange() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate khDate = LocalDate.of(2026, 4, 22);

                testDataHelper.createUrgentTask(user.getId(), khDate, "Today task");
                testDataHelper.createOneTimeSchedule(user.getId(), khDate, "Today block", 8, 9);

                updateMyTimezone(user, "America/New_York");

                mockMvc.perform(get("/api/v1/today/me")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", "2026-04-22"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.summary.totalTasks").value(1))
                        .andExpect(jsonPath("$.data.timeline.tasks.length()").value(1));
        }

        @Test
        void userProfileTimezone_shouldActuallyChangeButExistingPlanningObjectsShouldNotMove() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate khDate = LocalDate.of(2026, 4, 22);

                testDataHelper.createUrgentTask(user.getId(), khDate, "Stable task");
                testDataHelper.createOneTimeSchedule(user.getId(), khDate, "Stable block", 20, 21);

                updateMyTimezone(user, "America/Los_Angeles");

                mockMvc.perform(get("/api/v1/users/me").header("Authorization", authTestHelper.bearer(user)))
                        .andExpect(jsonPath("$.data.timezone").value("America/Los_Angeles"));

                mockMvc.perform(get("/api/v1/timeline/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", "2026-04-22"))
                        .andExpect(jsonPath("$.data.tasks[0].title").value("Stable task"))
                        .andExpect(jsonPath("$.data.schedules[0].title").value("Stable block"));
        }

        private void updateMyTimezone(User user, String timezone) throws Exception {
                UpdateUserProfileRequest request = new UpdateUserProfileRequest();
                request.setName(user.getName());
                request.setTimezone(timezone);
                request.setLocale(user.getLocale());

                mockMvc.perform(put("/api/v1/users/me")
                                .header("Authorization", authTestHelper.bearer(user))
                                .contentType("application/json")
                                .content(toJson(request)))
                        .andExpect(status().isOk());
        }
}