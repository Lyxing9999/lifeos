package com.lifeos.backend.schedule;

import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * PRODUCTION-GRADE END-TO-END TEST SUITE
 * Validates dynamic recurrence logic and lifecycle status.
 * * Architecture Note:
 * - Surface (/surfaces): Checks "Blueprint Existence" (Is the rule active in my life?).
 * - Select Options (/select-options): Checks "Occurrence" (Does this event happen specifically today?).
 */
class ScheduleRecurrenceE2ETest extends BaseE2ETest {

    @Test
    void recurrence_shouldIncludeMatchingBlocksInActiveList() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22); // A Wednesday

        testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Block", 8, 9);
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Block", 9, 10);
        testDataHelper.createWeeklySchedule(user.getId(), date, "Weekly Block", 10, 11);
        testDataHelper.createCustomWeeklySchedule(user.getId(), date, "Custom Gym", 18, 19, "WEDNESDAY");

        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(4)));
    }

    @Test
    void oneTime_shouldMoveToHistoryAfterDayPassed() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate startDate = LocalDate.of(2026, 4, 22);
        LocalDate nextDate = LocalDate.of(2026, 4, 23);

        testDataHelper.createOneTimeSchedule(user.getId(), startDate, "One-time Block", 8, 9);

        // On Start Date -> Should be in Active bucket
        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", startDate.toString()))
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(1)));

        // Day After -> Dynamically moved to History bucket because recurrence is NONE
        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", nextDate.toString()))
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(0)))
                .andExpect(jsonPath("$.data.historyBlocks", hasSize(1)))
                .andExpect(jsonPath("$.data.historyBlocks[0].title").value("One-time Block"));
    }

    @Test
    void daily_shouldAppearEveryDayAfterStartDate() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate startDate = LocalDate.of(2026, 4, 22);
        LocalDate nextDate = LocalDate.of(2026, 4, 23);

        testDataHelper.createDailySchedule(user.getId(), startDate, "Daily Block", 9, 10);

        // Rules stay active for all future dates unless paused
        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", nextDate.toString()))
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(1)))
                .andExpect(jsonPath("$.data.activeBlocks[0].title").value("Daily Block"));
    }

    @Test
    void weekly_shouldStayActiveEveryDayButOnlyOccurOnMatchingDay() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate wednesday = LocalDate.of(2026, 4, 22);
        LocalDate thursday = LocalDate.of(2026, 4, 23);

        testDataHelper.createWeeklySchedule(user.getId(), wednesday, "Weekly Wed", 10, 11);

        // Blueprint Surface: The rule is still ACTIVE on Thursday (we didn't pause it)
        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .param("date", thursday.toString())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(1)))
                .andExpect(jsonPath("$.data.activeBlocks[0].title").value("Weekly Wed"));

        // Occurrence Check: It does NOT appear in select-options on Thursday because it's not a Wednesday
        mockMvc.perform(get("/api/v1/schedules/me/select-options")
                        .param("date", thursday.toString())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    void customWeekly_shouldMatchSelectedDays() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate wednesday = LocalDate.of(2026, 4, 22);
        LocalDate friday = LocalDate.of(2026, 4, 24);
        LocalDate thursday = LocalDate.of(2026, 4, 23);

        testDataHelper.createCustomWeeklySchedule(user.getId(), wednesday, "M-W-F Gym", 18, 19, "MONDAY,WEDNESDAY,FRIDAY");

        // Surface: Rule exists as an active part of user's blueprint
        mockMvc.perform(get("/api/v1/schedules/me/surfaces").param("date", thursday.toString()).header("Authorization", authTestHelper.bearer(user)))
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(1)));

        // Select Options: Verified occurrence logic
        mockMvc.perform(get("/api/v1/schedules/me/select-options").param("date", friday.toString()).header("Authorization", authTestHelper.bearer(user)))
                .andExpect(jsonPath("$.data", hasSize(1)));

        mockMvc.perform(get("/api/v1/schedules/me/select-options").param("date", thursday.toString()).header("Authorization", authTestHelper.bearer(user)))
                .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    void monthly_shouldAppearOnSameDayOfMonth() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate startDate = LocalDate.of(2026, 4, 22);
        LocalDate nextMonthSameDay = LocalDate.of(2026, 5, 22);

        testDataHelper.createMonthlySchedule(user.getId(), startDate, "Monthly Review", 16, 17);

        // Occurrence Check for the same date next month
        mockMvc.perform(get("/api/v1/schedules/me/select-options")
                        .param("date", nextMonthSameDay.toString())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(jsonPath("$.data", hasSize(1)));
    }

    @Test
    void recurrence_shouldMoveToHistoryAfterEndDatePassed() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate start = LocalDate.of(2026, 4, 22);
        LocalDate end = LocalDate.of(2026, 4, 24);
        LocalDate afterEndDate = LocalDate.of(2026, 4, 25);

        testDataHelper.createScheduleWithEndDate(user.getId(), start, end, "Short Block", 9, 10, ScheduleRecurrenceType.DAILY);

        // Day After End Date -> Rule is no longer active, moved to historyBlocks bucket
        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", afterEndDate.toString()))
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(0)))
                .andExpect(jsonPath("$.data.historyBlocks", hasSize(1)))
                .andExpect(jsonPath("$.data.historyBlocks[0].title").value("Short Block"));
    }
}