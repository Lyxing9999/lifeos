package com.lifeos.backend.task;

import com.lifeos.backend.auth.domain.LifeOsPrincipal;
import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.time.LocalDate;
import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TaskRecurringCompletionE2ETest extends BaseE2ETest {

    @Test
    void dailyTask_completedYesterday_shouldAppearAgainTodayAsTodo() throws Exception {
        User user = testDataHelper.createUser();

        LocalDate yesterday = LocalDate.of(2026, 5, 1);
        LocalDate today = LocalDate.of(2026, 5, 2);

        var task = testDataHelper.createDailyTask(
                user.getId(),
                yesterday,
                "Drink water"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .with(authenticatedAs(user))
                        .param("date", yesterday.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(task.getId().toString()))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.completedAt").exists());

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .with(authenticatedAs(user))
                        .param("date", today.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[0].id").value(task.getId().toString()))
                .andExpect(jsonPath("$.data[0].title").value("Drink water"))
                .andExpect(jsonPath("$.data[0].status").value("TODO"))
                .andExpect(jsonPath("$.data[0].completedAt").doesNotExist());
    }

    @Test
    void dailyTask_canBeCompletedOnMultipleDifferentDays() throws Exception {
        User user = testDataHelper.createUser();

        LocalDate day1 = LocalDate.of(2026, 5, 1);
        LocalDate day2 = LocalDate.of(2026, 5, 2);

        var task = testDataHelper.createDailyTask(
                user.getId(),
                day1,
                "Read 10 pages"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .with(authenticatedAs(user))
                        .param("date", day1.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("COMPLETED"));

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .with(authenticatedAs(user))
                        .param("date", day2.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("COMPLETED"));

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .with(authenticatedAs(user))
                        .param("date", day1.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].status").value("COMPLETED"))
                .andExpect(jsonPath("$.data[0].completedAt").exists());

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .with(authenticatedAs(user))
                        .param("date", day2.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].status").value("COMPLETED"))
                .andExpect(jsonPath("$.data[0].completedAt").exists());
    }

    @Test
    void dailyTask_reopenToday_shouldOnlyReopenTodayOccurrence() throws Exception {
        User user = testDataHelper.createUser();

        LocalDate day1 = LocalDate.of(2026, 5, 1);
        LocalDate day2 = LocalDate.of(2026, 5, 2);

        var task = testDataHelper.createDailyTask(
                user.getId(),
                day1,
                "Stretch"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .with(authenticatedAs(user))
                        .param("date", day1.toString()))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .with(authenticatedAs(user))
                        .param("date", day2.toString()))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/v1/tasks/{taskId}/reopen", task.getId())
                        .with(authenticatedAs(user))
                        .param("date", day2.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("TODO"))
                .andExpect(jsonPath("$.data.completedAt").doesNotExist());

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .with(authenticatedAs(user))
                        .param("date", day1.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].status").value("COMPLETED"))
                .andExpect(jsonPath("$.data[0].completedAt").exists());

        mockMvc.perform(get("/api/v1/tasks/me/day")
                        .with(authenticatedAs(user))
                        .param("date", day2.toString())
                        .param("filter", "ALL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].status").value("TODO"))
                .andExpect(jsonPath("$.data[0].completedAt").doesNotExist());
    }

    @Test
    void oneTimeTask_completeWithoutDate_shouldStillUseGlobalCompletion() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createUrgentTask(
                user.getId(),
                date,
                "Submit invoice"
        );

        mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                        .with(authenticatedAs(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.completedAt").exists());
    }

    private RequestPostProcessor authenticatedAs(User user) {
        LifeOsPrincipal principal = new LifeOsPrincipal(
                user.getId(),
                user.getEmail()
        );

        UsernamePasswordAuthenticationToken token =
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        List.of()
                );

        return authentication(token);
    }
}