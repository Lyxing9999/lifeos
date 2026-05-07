package com.lifeos.backend.core;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class CoreDayModelE2ETest extends BaseE2ETest {

    @Test
    void coreDayModel_shouldKeepTaskScheduleTimelineAndTodayConsistent() throws Exception {
        User user = testDataHelper.createUser();

        LocalDate day = LocalDate.of(2026, 5, 1);

        var workBlock = testDataHelper.createOneTimeSchedule(
                user.getId(),
                day,
                "Morning Work",
                8,
                10
        );

        testDataHelper.createUrgentTaskLinkedToSchedule(
                user.getId(),
                day,
                "Review proposal",
                workBlock.getId()
        );

        testDataHelper.createUrgentTask(
                user.getId(),
                day,
                "Pay rent"
        );

        var dailyTask = testDataHelper.createDailyTask(
                user.getId(),
                day,
                "Drink water"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", dailyTask.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", day.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.completedAt").exists());

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", day.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(3))
                .andExpect(jsonPath("$.data[?(@.title=='Review proposal')]").exists())
                .andExpect(jsonPath("$.data[?(@.title=='Pay rent')]").exists())
                .andExpect(jsonPath("$.data[?(@.title=='Drink water')]").exists())
                .andExpect(jsonPath("$.data[?(@.title=='Drink water' && @.status=='COMPLETED')]").exists());

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", day.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.tasks.length()").value(3))
                .andExpect(jsonPath("$.data.tasks[?(@.title=='Review proposal')]").exists())
                .andExpect(jsonPath("$.data.tasks[?(@.title=='Pay rent')]").exists())
                .andExpect(jsonPath("$.data.tasks[?(@.title=='Drink water' && @.status=='COMPLETED')]").exists())
                .andExpect(jsonPath("$.data.schedules.length()").value(1))
                .andExpect(jsonPath("$.data.summary.totalTasks").value(3))
                .andExpect(jsonPath("$.data.summary.completedTasks").value(1))
                .andExpect(jsonPath("$.data.summary.totalPlannedBlocks").value(1))
                .andExpect(jsonPath("$.data.items[?(@.itemType=='SCHEDULE' && @.title=='Morning Work')]").exists())
                .andExpect(jsonPath("$.data.items[?(@.itemType=='TASK' && @.title=='Review proposal')]").doesNotExist());

        mockMvc.perform(get("/api/v1/today/me")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", day.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.date").value(day.toString()))
                .andExpect(jsonPath("$.data.currentScheduleBlock").exists())
                .andExpect(jsonPath("$.data.currentScheduleBlock.scheduleBlockId").value(workBlock.getId().toString()))
                .andExpect(jsonPath("$.data.currentScheduleBlock.title").value("Morning Work"))
                .andExpect(jsonPath("$.data.summary.totalTasks").value(3))
                .andExpect(jsonPath("$.data.summary.completedTasks").value(1))
                .andExpect(jsonPath("$.data.summary.totalPlannedBlocks").value(1))
                .andExpect(jsonPath("$.data.score.totalTasks").value(3))
                .andExpect(jsonPath("$.data.score.completedTasks").value(1))
                .andExpect(jsonPath("$.data.score.totalPlannedBlocks").value(1))
                .andExpect(jsonPath("$.data.timeline.summary.totalTasks").value(3))
                .andExpect(jsonPath("$.data.timeline.summary.completedTasks").value(1))
                .andExpect(jsonPath("$.data.timeline.summary.totalPlannedBlocks").value(1))
                .andExpect(jsonPath("$.data.timeline.items[?(@.itemType=='TASK' && @.title=='Review proposal')]").doesNotExist());
    }

    @Test
    void recurringTaskCompletion_shouldBePerDayNotGlobal() throws Exception {
        User user = testDataHelper.createUser();

        LocalDate day1 = LocalDate.of(2026, 5, 1);
        LocalDate day2 = LocalDate.of(2026, 5, 2);

        var dailyTask = testDataHelper.createDailyTask(
                user.getId(),
                day1,
                "Read daily"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", dailyTask.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", day1.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("COMPLETED"));

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", day1.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[?(@.title=='Read daily' && @.status=='COMPLETED')]").exists())
                .andExpect(jsonPath("$.data[?(@.title=='Read daily' && @.completedAt != null)]").exists());

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", day2.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[?(@.title=='Read daily' && @.status=='TODO')]").exists())
                .andExpect(jsonPath("$.data[?(@.title=='Read daily' && @.completedAt == null)]").exists());
    }

    @Test
    void coreDayModel_shouldNeverLeakOtherUsersData() throws Exception {
        User user = testDataHelper.createUser();
        User otherUser = testDataHelper.createUser();

        LocalDate day = LocalDate.of(2026, 5, 1);

        testDataHelper.createUrgentTask(user.getId(), day, "My task");
        testDataHelper.createUrgentTask(otherUser.getId(), day, "Other user task");

        testDataHelper.createOneTimeSchedule(user.getId(), day, "My block", 8, 9);
        testDataHelper.createOneTimeSchedule(otherUser.getId(), day, "Other user block", 9, 10);

        mockMvc.perform(get("/api/v1/today/me")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", day.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.user.id").value(user.getId().toString()))
                .andExpect(jsonPath("$.data.timeline.tasks[?(@.title=='My task')]").exists())
                .andExpect(jsonPath("$.data.timeline.tasks[?(@.title=='Other user task')]").doesNotExist())
                .andExpect(jsonPath("$.data.timeline.schedules[?(@.title=='My block')]").exists())
                .andExpect(jsonPath("$.data.timeline.schedules[?(@.title=='Other user block')]").doesNotExist());
    }
}