package com.lifeos.backend.today;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TodayRecurringLinkedScheduleE2ETest extends BaseE2ETest {

    @Test
    void today_withDailyTaskLinkedToDailySchedule_shouldSuppressTopTaskAndAvoidDuplicateTimelineItem() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var schedule = testDataHelper.createDailySchedule(
                user.getId(),
                date,
                "Daily Work Block",
                9,
                10
        );

        testDataHelper.createDailyTaskLinkedToSchedule(
                user.getId(),
                date,
                "Daily work task",
                schedule.getId()
        );

        mockMvc.perform(get("/api/v1/today/me")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.currentScheduleBlock").exists())
                .andExpect(jsonPath("$.data.currentScheduleBlock.scheduleBlockId").value(schedule.getId().toString()))

                // Task is represented by the schedule context, so no duplicate top task.
                .andExpect(jsonPath("$.data.topActiveTask").doesNotExist())

                // Source models exist.
                .andExpect(jsonPath("$.data.timeline.tasks.length()").value(1))
                .andExpect(jsonPath("$.data.timeline.schedules.length()").value(1))

                // Unified timeline avoids duplicate row.
                .andExpect(jsonPath("$.data.timeline.items.length()").value(1))
                .andExpect(jsonPath("$.data.timeline.items[0].itemType").value("SCHEDULE"));
    }
}