package com.lifeos.backend.timeline;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TimelineControllerE2ETest extends BaseE2ETest {

    @Test
    void getDay_shouldReturnMergedTaskAndScheduleItems() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22); // Wednesday

        testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Wednesday Block", 8, 9);
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
        testDataHelper.createWeeklySchedule(user.getId(), date, "Weekly Wednesday Review", 10, 11);
        testDataHelper.createCustomWeeklySchedule(user.getId(), date, "Custom Wednesday Gym", 18, 19, "WEDNESDAY");

        testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");

        mockMvc.perform(get("/api/v1/timeline/user/{userId}/day", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                .andExpect(jsonPath("$.data.date").value("2026-04-22"))
                .andExpect(jsonPath("$.data.items").isArray())
                .andExpect(jsonPath("$.data.items.length()").value(6))
                .andExpect(jsonPath("$.data.schedules.length()").value(4))
                .andExpect(jsonPath("$.data.tasks.length()").value(3))
                .andExpect(jsonPath("$.data.summary.totalPlannedBlocks").value(4))
                .andExpect(jsonPath("$.data.summary.totalTasks").value(3));
    }
    @Test
    void getDay_shouldIncludeScheduleAndTaskItemTypes() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
        testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");

        mockMvc.perform(get("/api/v1/timeline/user/{userId}/day", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.items").isArray())
                .andExpect(jsonPath("$.data.items.length()").value(2))
                .andExpect(jsonPath("$.data.items[0].itemType").value("SCHEDULE"))
                .andExpect(jsonPath("$.data.items[0].title").value("Daily Planning Block"))
                .andExpect(jsonPath("$.data.items[1].itemType").value("TASK"))
                .andExpect(jsonPath("$.data.items[1].title").value("Urgent task"));
    }

    @Test
    void getDay_shouldRespectCustomWeeklyAndNotLeakToNonMatchingDay() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate wednesday = LocalDate.of(2026, 4, 22);
        LocalDate thursday = LocalDate.of(2026, 4, 23);

        testDataHelper.createCustomWeeklySchedule(
                user.getId(),
                wednesday,
                "Custom Wednesday Gym",
                18,
                19,
                "WEDNESDAY"
        );

        mockMvc.perform(get("/api/v1/timeline/user/{userId}/day", user.getId())
                        .param("date", wednesday.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.items.length()").value(1))
                .andExpect(jsonPath("$.data.items[0].itemType").value("SCHEDULE"))
                .andExpect(jsonPath("$.data.items[0].title").value("Custom Wednesday Gym"));

        mockMvc.perform(get("/api/v1/timeline/user/{userId}/day", user.getId())
                        .param("date", thursday.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.items.length()").value(0))
                .andExpect(jsonPath("$.data.schedules.length()").value(0));
    }
}