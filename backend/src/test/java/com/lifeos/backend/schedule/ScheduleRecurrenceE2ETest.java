package com.lifeos.backend.schedule;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ScheduleRecurrenceE2ETest extends BaseE2ETest {

    @Test
    void recurrence_shouldIncludeDailyWeeklyAndCustomWeeklyOnMatchingDay() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22); // Wednesday

        testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Wednesday Block", 8, 9);
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
        testDataHelper.createWeeklySchedule(user.getId(), date, "Weekly Wednesday Review", 10, 11);
        testDataHelper.createCustomWeeklySchedule(user.getId(), date, "Custom Wednesday Gym", 18, 19, "WEDNESDAY");

        mockMvc.perform(get("/api/v1/schedules/user/{userId}/day", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(4))
                .andExpect(jsonPath("$.data[0].title").value("One-time Wednesday Block"))
                .andExpect(jsonPath("$.data[1].title").value("Daily Planning Block"))
                .andExpect(jsonPath("$.data[2].title").value("Weekly Wednesday Review"))
                .andExpect(jsonPath("$.data[3].title").value("Custom Wednesday Gym"));
    }

    @Test
    void customWeekly_shouldNotAppearOnNonMatchingDay() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate startDate = LocalDate.of(2026, 4, 22); // Wednesday
        LocalDate nonMatchingDate = LocalDate.of(2026, 4, 23); // Thursday

        testDataHelper.createCustomWeeklySchedule(
                user.getId(),
                startDate,
                "Custom Wednesday Gym",
                18,
                19,
                "WEDNESDAY"
        );

        mockMvc.perform(get("/api/v1/schedules/user/{userId}/day", user.getId())
                        .param("date", nonMatchingDate.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(0));
    }
}