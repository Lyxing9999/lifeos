package com.lifeos.backend.timeline;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TimelineRecurringLinkedScheduleE2ETest extends BaseE2ETest {

    @Test
    void dailyTaskLinkedToDailySchedule_shouldNotCreateDuplicateTimelineItems() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate startDate = LocalDate.of(2026, 5, 1);

        var schedule = testDataHelper.createDailySchedule(
                user.getId(),
                startDate,
                "Daily Work Block",
                9,
                10
        );

        var task = testDataHelper.createDailyTaskLinkedToSchedule(
                user.getId(),
                startDate,
                "Daily work task",
                schedule.getId()
        );

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", startDate.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                // Data still contains both source models.
                .andExpect(jsonPath("$.data.tasks.length()").value(1))
                .andExpect(jsonPath("$.data.tasks[0].id").value(task.getId().toString()))
                .andExpect(jsonPath("$.data.tasks[0].linkedScheduleBlockId").value(schedule.getId().toString()))
                .andExpect(jsonPath("$.data.schedules.length()").value(1))
                .andExpect(jsonPath("$.data.schedules[0].scheduleBlockId").value(schedule.getId().toString()))

                // But unified timeline shows only schedule, not duplicate task row.
                .andExpect(jsonPath("$.data.items.length()").value(1))
                .andExpect(jsonPath("$.data.items[0].itemType").value("SCHEDULE"))
                .andExpect(jsonPath("$.data.items[0].itemId").value(schedule.getId().toString()));
    }

    @Test
    void dailyTaskLinkedToDailySchedule_shouldNotDuplicateOnFutureOccurrence() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate startDate = LocalDate.of(2026, 5, 1);
        LocalDate futureDate = LocalDate.of(2026, 5, 2);

        var schedule = testDataHelper.createDailySchedule(
                user.getId(),
                startDate,
                "Daily Work Block",
                9,
                10
        );

        var task = testDataHelper.createDailyTaskLinkedToSchedule(
                user.getId(),
                startDate,
                "Daily work task",
                schedule.getId()
        );

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", futureDate.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.tasks.length()").value(1))
                .andExpect(jsonPath("$.data.tasks[0].id").value(task.getId().toString()))
                .andExpect(jsonPath("$.data.schedules.length()").value(1))

                // Still no duplicate on future recurring day.
                .andExpect(jsonPath("$.data.items.length()").value(1))
                .andExpect(jsonPath("$.data.items[0].itemType").value("SCHEDULE"));
    }

    @Test
    void dailyTaskLinkedToSchedule_shouldCreateStandaloneTaskWhenScheduleDoesNotOccurThatDay() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate wednesday = LocalDate.of(2026, 4, 22);
        LocalDate thursday = LocalDate.of(2026, 4, 23);

        var schedule = testDataHelper.createCustomWeeklySchedule(
                user.getId(),
                wednesday,
                "Wednesday Work Block",
                9,
                10,
                "WEDNESDAY"
        );

        var task = testDataHelper.createDailyTaskLinkedToSchedule(
                user.getId(),
                wednesday,
                "Daily task linked to Wednesday block",
                schedule.getId()
        );

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", thursday.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                // Daily task is relevant.
                .andExpect(jsonPath("$.data.tasks.length()").value(1))
                .andExpect(jsonPath("$.data.tasks[0].id").value(task.getId().toString()))

                // Wednesday schedule does not occur on Thursday.
                .andExpect(jsonPath("$.data.schedules.length()").value(0))

                // Since linked schedule does not occur, task can stand alone.
                .andExpect(jsonPath("$.data.items.length()").value(1))
                .andExpect(jsonPath("$.data.items[0].itemType").value("TASK"))
                .andExpect(jsonPath("$.data.items[0].itemId").value(task.getId().toString()));
    }
}