package com.lifeos.backend.core;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class CoreTaskTodayTimelineFlowE2ETest extends BaseE2ETest {

    @Test
    void oneTimeTask_completeReopenArchiveRestore_shouldUpdateTodayAndTimeline() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createUrgentTask(
                user.getId(),
                date,
                "Ship task flow"
        );

        assertTodayAndTimeline(user, date, 1, 0, true, "TODO");

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.achievedDate").value(date.toString()));

        assertTodayAndTimeline(user, date, 1, 1, false, "COMPLETED");

        mockMvc.perform(get("/api/v1/tasks/me/history")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[?(@.title=='Ship task flow' && @.status=='COMPLETED')]").exists());

        mockMvc.perform(post("/api/v1/tasks/{taskId}/reopen", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("TODO"))
                .andExpect(jsonPath("$.data.completedAt").doesNotExist())
                .andExpect(jsonPath("$.data.achievedDate").doesNotExist());

        assertTodayAndTimeline(user, date, 1, 0, true, "TODO");

        mockMvc.perform(post("/api/v1/tasks/{taskId}/archive", task.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.archived").value(true));

        assertTodayAndTimelineWithoutTask(user, date);

        mockMvc.perform(post("/api/v1/tasks/{taskId}/restore", task.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.archived").value(false));

        assertTodayAndTimeline(user, date, 1, 0, true, "TODO");
    }

    @Test
    void recurringTask_completeReopenArchiveRestore_shouldUpdateOnlySelectedDay() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate dayOne = LocalDate.of(2026, 5, 1);
        LocalDate dayTwo = LocalDate.of(2026, 5, 2);

        var task = testDataHelper.createDailyTask(
                user.getId(),
                dayOne,
                "Daily workout"
        );

        assertTodayAndTimeline(user, dayOne, 1, 0, true, "TODO");
        assertTodayAndTimeline(user, dayTwo, 1, 0, true, "TODO");

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", dayOne.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.achievedDate").value(dayOne.toString()));

        assertTodayAndTimeline(user, dayOne, 1, 1, false, "COMPLETED");
        assertTodayAndTimeline(user, dayTwo, 1, 0, true, "TODO");

        mockMvc.perform(post("/api/v1/tasks/{taskId}/reopen", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", dayOne.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("TODO"));

        assertTodayAndTimeline(user, dayOne, 1, 0, true, "TODO");

        mockMvc.perform(post("/api/v1/tasks/{taskId}/archive", task.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.archived").value(true));

        assertTodayAndTimelineWithoutTask(user, dayOne);
        assertTodayAndTimelineWithoutTask(user, dayTwo);

        mockMvc.perform(post("/api/v1/tasks/{taskId}/restore", task.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.archived").value(false));

        assertTodayAndTimeline(user, dayOne, 1, 0, true, "TODO");
        assertTodayAndTimeline(user, dayTwo, 1, 0, true, "TODO");
    }

    @Test
    void completedRecurringTask_archiveRestore_shouldPreserveSelectedDayCompletion() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createDailyTask(
                user.getId(),
                date,
                "Daily focus"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.achievedDate").value(date.toString()));

        assertTodayAndTimeline(user, date, 1, 1, false, "COMPLETED");

        mockMvc.perform(post("/api/v1/tasks/{taskId}/archive", task.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        assertTodayAndTimelineWithoutTask(user, date);

        mockMvc.perform(post("/api/v1/tasks/{taskId}/restore", task.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        assertTodayAndTimeline(user, date, 1, 1, false, "COMPLETED");
    }

    @Test
    void clearDone_shouldHideRecurringCompletedTaskFromDoneButKeepHistoryTodayAndTimeline() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createDailyTask(
                user.getId(),
                date,
                "Daily focus"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.completedAt").exists())
                .andExpect(jsonPath("$.data.achievedDate").value(date.toString()));

        assertDoneViewCount(user, date, 1);

        mockMvc.perform(post("/api/v1/tasks/me/done/clear")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        assertDoneViewCount(user, date, 0);

        mockMvc.perform(get("/api/v1/tasks/me/history")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[?(@.title=='Daily focus' && @.status=='COMPLETED')]").exists());

        assertTodayAndTimeline(user, date, 1, 1, false, "COMPLETED");
    }

    @Test
    void clearDone_shouldHideNormalCompletedTaskFromDoneButKeepHistoryTodayAndTimeline() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createUrgentTask(
                user.getId(),
                date,
                "Pay rent"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.achievedDate").value(date.toString()));

        assertDoneViewCount(user, date, 1);

        mockMvc.perform(post("/api/v1/tasks/me/done/clear")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        assertDoneViewCount(user, date, 0);

        mockMvc.perform(get("/api/v1/tasks/me/history")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[?(@.title=='Pay rent' && @.status=='COMPLETED')]").exists());

        assertTodayAndTimeline(user, date, 0, 0, false, "COMPLETED");
    }

    @Test
    void inboxTask_complete_shouldMoveToHistoryForSelectedDate() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createTaskWithoutDueDate(
                user.getId(),
                "Buy shoes"
        );

        mockMvc.perform(get("/api/v1/tasks/me/inbox")
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[?(@.title=='Buy shoes')]").exists());

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[?(@.title=='Buy shoes')]").doesNotExist());

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.achievedDate").value(date.toString()));

        mockMvc.perform(get("/api/v1/tasks/me/inbox")
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[?(@.title=='Buy shoes')]").doesNotExist());

        mockMvc.perform(get("/api/v1/tasks/me/history")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[?(@.title=='Buy shoes' && @.status=='COMPLETED')]").exists());
    }

    @Test
    void pauseResume_shouldHideAndRestoreTaskFromTodayAndTimeline() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createDailyTask(
                user.getId(),
                date,
                "Study English"
        );

        assertTodayAndTimeline(user, date, 1, 0, true, "TODO");

        mockMvc.perform(post("/api/v1/tasks/{taskId}/pause", task.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.paused").value(true))
                .andExpect(jsonPath("$.data.pausedAt").exists());

        assertTodayAndTimelineWithoutTask(user, date);

        mockMvc.perform(get("/api/v1/tasks/me/paused")
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[?(@.title=='Study English' && @.paused==true)]").exists());

        mockMvc.perform(post("/api/v1/tasks/{taskId}/resume", task.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.paused").value(false));

        assertTodayAndTimeline(user, date, 1, 0, true, "TODO");
    }

    private void assertDoneViewCount(
            User user,
            LocalDate date,
            int expectedCount
    ) throws Exception {
        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString())
                        .param("filter", "COMPLETED"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(expectedCount));
    }

    private void assertTodayAndTimeline(
            User user,
            LocalDate date,
            int totalTasks,
            int completedTasks,
            boolean expectTopActiveTask,
            String expectedTaskStatus
    ) throws Exception {
        mockMvc.perform(get("/api/v1/today/me")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.summary.totalTasks").value(totalTasks))
                .andExpect(jsonPath("$.data.summary.completedTasks").value(completedTasks))
                .andExpect(jsonPath("$.data.score.totalTasks").value(totalTasks))
                .andExpect(jsonPath("$.data.score.completedTasks").value(completedTasks))
                .andExpect(jsonPath("$.data.timeline.summary.totalTasks").value(totalTasks))
                .andExpect(jsonPath("$.data.timeline.summary.completedTasks").value(completedTasks))
                .andExpect(expectTopActiveTask
                        ? jsonPath("$.data.topActiveTask").exists()
                        : jsonPath("$.data.topActiveTask").doesNotExist());

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.summary.totalTasks").value(totalTasks))
                .andExpect(jsonPath("$.data.summary.completedTasks").value(completedTasks))
                .andExpect(jsonPath("$.data.tasks.length()").value(totalTasks))
                .andExpect(totalTasks == 0
                        ? jsonPath("$.data.tasks").isArray()
                        : jsonPath("$.data.tasks[?(@.status=='" + expectedTaskStatus + "')]").exists());
    }

    private void assertTodayAndTimelineWithoutTask(
            User user,
            LocalDate date
    ) throws Exception {
        mockMvc.perform(get("/api/v1/today/me")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.summary.totalTasks").value(0))
                .andExpect(jsonPath("$.data.summary.completedTasks").value(0))
                .andExpect(jsonPath("$.data.score.totalTasks").value(0))
                .andExpect(jsonPath("$.data.score.completedTasks").value(0))
                .andExpect(jsonPath("$.data.timeline.summary.totalTasks").value(0))
                .andExpect(jsonPath("$.data.timeline.summary.completedTasks").value(0))
                .andExpect(jsonPath("$.data.topActiveTask").doesNotExist());

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.summary.totalTasks").value(0))
                .andExpect(jsonPath("$.data.summary.completedTasks").value(0))
                .andExpect(jsonPath("$.data.tasks.length()").value(0))
                .andExpect(jsonPath("$.data.items[?(@.itemType=='TASK')]").doesNotExist());
    }
}