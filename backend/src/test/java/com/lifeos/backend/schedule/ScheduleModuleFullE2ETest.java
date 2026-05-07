package com.lifeos.backend.schedule;

import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.request.UpdateScheduleBlockRequest;
import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * PRODUCTION-GRADE END-TO-END TEST SUITE
 * Domain: Schedule (The Blueprint)
 * Architecture: CQRS + BFF Surface Pattern
 * * Logic Note:
 * - Active: Living rules that apply to the user's current life stage.
 * - Inactive: Manually paused/deactivated rules.
 * - History: One-time or end-dated rules that have passed their time.
 */
public class ScheduleModuleFullE2ETest extends BaseE2ETest {

    @Nested
    @DisplayName("Surface & Lifecycle Tests")
    class SurfaceLifecycleTests {

        @Test
        @DisplayName("Should categorize blocks into Active, Inactive, and History lists based on requested date")
        void testSurfaceBffCategorization() throws Exception {
            User user = testDataHelper.createUser();
            String token = authTestHelper.bearer(user);

            // Context: May 6th is a Wednesday
            LocalDate today = LocalDate.of(2026, 5, 6);
            LocalDate tomorrow = today.plusDays(1);

            // 1. One-time block (Active today, History tomorrow)
            testDataHelper.createOneTimeSchedule(user.getId(), today, "One-Time Today", 8, 9);

            // 2. Daily block (Active both days)
            testDataHelper.createDailySchedule(user.getId(), today, "Daily Routine", 10, 11);

            // 3. Custom Weekly for Monday/Friday (Remains ACTIVE blueprint on Wednesday)
            testDataHelper.createCustomWeeklySchedule(user.getId(), today.minusDays(2), "Mon/Fri Gym", 17, 18, "MONDAY,FRIDAY");

            // 4. Manually Deactivated block
            var deactivated = testDataHelper.createOneTimeSchedule(user.getId(), today, "Paused Work", 14, 15);
            mockMvc.perform(post("/api/v1/schedules/{id}/deactivate", deactivated.getId()).header("Authorization", token))
                    .andExpect(status().isOk());

            // --- STEP 1: VERIFY WEDNESDAY SURFACE ---
            mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                            .param("date", today.toString())
                            .header("Authorization", token))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.date").value(today.toString()))
                    // Count = One-Time + Daily + Mon/Fri Gym (blueprint is active even if it doesn't occur today)
                    .andExpect(jsonPath("$.data.counts.active").value(3))
                    .andExpect(jsonPath("$.data.counts.inactive").value(1)) // Just the Paused Work
                    .andExpect(jsonPath("$.data.activeBlocks", hasSize(3)))
                    .andExpect(jsonPath("$.data.activeBlocks[*].title", hasItems("One-Time Today", "Daily Routine", "Mon/Fri Gym")))
                    .andExpect(jsonPath("$.data.inactiveBlocks[0].title").value("Paused Work"));

            // --- STEP 2: VERIFY THURSDAY SURFACE ---
            mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                            .param("date", tomorrow.toString())
                            .header("Authorization", token))
                    .andExpect(status().isOk())
                    // Count = Daily + Mon/Fri Gym (One-Time has expired)
                    .andExpect(jsonPath("$.data.counts.active").value(2))
                    .andExpect(jsonPath("$.data.activeBlocks", hasSize(2)))
                    .andExpect(jsonPath("$.data.activeBlocks[*].title", hasItems("Daily Routine", "Mon/Fri Gym")))
                    // Verification of dynamic expiration into History
                    .andExpect(jsonPath("$.data.historyBlocks", hasSize(1)))
                    .andExpect(jsonPath("$.data.historyBlocks[0].title").value("One-Time Today"));
        }
    }

    @Nested
    @DisplayName("Mutation Command Tests")
    class MutationTests {

        @Test
        @DisplayName("Should update an existing block and reflect immediately in the query side")
        void testUpdateIntegrity() throws Exception {
            User user = testDataHelper.createUser();
            String token = authTestHelper.bearer(user);
            var block = testDataHelper.createOneTimeSchedule(user.getId(), LocalDate.now(), "Old Title", 9, 10);

            UpdateScheduleBlockRequest update = new UpdateScheduleBlockRequest();
            update.setTitle("New Title");
            update.setEndTime(LocalTime.of(12, 0));

            mockMvc.perform(patch("/api/v1/schedules/{id}", block.getId())
                            .header("Authorization", token)
                            .contentType(json)
                            .content(toJson(update)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.title").value("New Title"))
                    .andExpect(jsonPath("$.data.endTime").value("12:00:00"));

            mockMvc.perform(get("/api/v1/schedules/{id}", block.getId()).header("Authorization", token))
                    .andExpect(jsonPath("$.data.title").value("New Title"));
        }

        @Test
        @DisplayName("Should activate a deactivated block and return it to the active surface")
        void testActivationLifecycle() throws Exception {
            User user = testDataHelper.createUser();
            String token = authTestHelper.bearer(user);
            LocalDate date = LocalDate.now();
            var block = testDataHelper.createOneTimeSchedule(user.getId(), date, "Toggle Block", 8, 9);

            mockMvc.perform(post("/api/v1/schedules/{id}/deactivate", block.getId()).header("Authorization", token));

            mockMvc.perform(get("/api/v1/schedules/me/surfaces").param("date", date.toString()).header("Authorization", token))
                    .andExpect(jsonPath("$.data.activeBlocks", hasSize(0)))
                    .andExpect(jsonPath("$.data.inactiveBlocks", hasSize(1)));

            mockMvc.perform(post("/api/v1/schedules/{id}/activate", block.getId()).header("Authorization", token))
                    .andExpect(status().isOk());

            mockMvc.perform(get("/api/v1/schedules/me/surfaces").param("date", date.toString()).header("Authorization", token))
                    .andExpect(jsonPath("$.data.activeBlocks", hasSize(1)));
        }
    }

    @Nested
    @DisplayName("Boundary & Validation Tests")
    class ValidationTests {

        @Test
        @DisplayName("Should reject time ranges where start is after end")
        void rejectInvalidTimeRange() throws Exception {
            User user = testDataHelper.createUser();
            CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
            request.setTitle("Bad Time");
            request.setStartTime(LocalTime.of(20, 0));
            request.setEndTime(LocalTime.of(19, 0));
            request.setRecurrenceStartDate(LocalDate.now());

            mockMvc.perform(post("/api/v1/schedules")
                            .header("Authorization", authTestHelper.bearer(user))
                            .contentType(json)
                            .content(toJson(request)))
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("Should reject CUSTOM_WEEKLY recurrence if no days are provided")
        void rejectInvalidCustomWeekly() throws Exception {
            User user = testDataHelper.createUser();
            CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
            request.setTitle("No Days");
            request.setStartTime(LocalTime.of(9, 0));
            request.setEndTime(LocalTime.of(10, 0));
            request.setRecurrenceType(ScheduleRecurrenceType.CUSTOM_WEEKLY);
            request.setRecurrenceStartDate(LocalDate.now());

            mockMvc.perform(post("/api/v1/schedules")
                            .header("Authorization", authTestHelper.bearer(user))
                            .contentType(json)
                            .content(toJson(request)))
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("Should prevent user A from modifying user B's schedule")
        void enforceOwnershipSecurity() throws Exception {
            User userA = testDataHelper.createUser();
            User userB = testDataHelper.createUser();
            var blockA = testDataHelper.createOneTimeSchedule(userA.getId(), LocalDate.now(), "A's Block", 8, 9);

            UpdateScheduleBlockRequest attack = new UpdateScheduleBlockRequest();
            attack.setTitle("Hacked");

            mockMvc.perform(patch("/api/v1/schedules/{id}", blockA.getId())
                            .header("Authorization", authTestHelper.bearer(userB))
                            .contentType(json)
                            .content(toJson(attack)))
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("Recurrence Edge Cases")
    class RecurrenceTests {

        @Test
        @DisplayName("Monthly recurrence should only appear as an option on matching days")
        void testMonthlyRecurrence() throws Exception {
            User user = testDataHelper.createUser();
            String token = authTestHelper.bearer(user);
            LocalDate start = LocalDate.of(2026, 1, 15);
            LocalDate nextMonth = LocalDate.of(2026, 2, 15);
            LocalDate wrongDay = LocalDate.of(2026, 2, 16);

            testDataHelper.createMonthlySchedule(user.getId(), start, "Rent Payment", 9, 10);

            // Occurs on the 15th
            mockMvc.perform(get("/api/v1/schedules/me/select-options").param("date", nextMonth.toString()).header("Authorization", token))
                    .andExpect(jsonPath("$.data", hasSize(1)));

            // Does not occur on the 16th
            mockMvc.perform(get("/api/v1/schedules/me/select-options").param("date", wrongDay.toString()).header("Authorization", token))
                    .andExpect(jsonPath("$.data", hasSize(0)));
        }

        @Test
        @DisplayName("Should stop returning active blocks once the Recurrence End Date is passed")
        void testExpirationByEndDate() throws Exception {
            User user = testDataHelper.createUser();
            String token = authTestHelper.bearer(user);
            LocalDate end = LocalDate.of(2026, 5, 5);
            LocalDate afterEnd = LocalDate.of(2026, 5, 6);

            testDataHelper.createScheduleWithEndDate(user.getId(), end.minusDays(2), end, "Short Term", 8, 9, ScheduleRecurrenceType.DAILY);

            // Still active on the end date
            mockMvc.perform(get("/api/v1/schedules/me/surfaces").param("date", end.toString()).header("Authorization", token))
                    .andExpect(jsonPath("$.data.activeBlocks", hasSize(1)));

            // Moved to history blocks after the end date
            mockMvc.perform(get("/api/v1/schedules/me/surfaces").param("date", afterEnd.toString()).header("Authorization", token))
                    .andExpect(jsonPath("$.data.activeBlocks", hasSize(0)))
                    .andExpect(jsonPath("$.data.historyBlocks", hasSize(1)))
                    .andExpect(jsonPath("$.data.historyBlocks[0].title").value("Short Term"));
        }
    }
}