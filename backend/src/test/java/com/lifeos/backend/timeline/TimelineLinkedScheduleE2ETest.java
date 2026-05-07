package com.lifeos.backend.timeline;

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
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TimelineLinkedScheduleE2ETest extends BaseE2ETest {

    @Test
    void linkedTask_shouldNotCreateDuplicateTimelineItemWhenScheduleOccursThatDay() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var schedule = testDataHelper.createOneTimeSchedule(
                user.getId(),
                date,
                "Morning Work",
                8,
                10
        );

        var linkedTask = testDataHelper.createUrgentTaskLinkedToSchedule(
                user.getId(),
                date,
                "Review proposal",
                schedule.getId()
        );

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .with(authenticatedAs(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.schedules.length()").value(1))
                .andExpect(jsonPath("$.data.tasks.length()").value(1))
                .andExpect(jsonPath("$.data.summary.totalPlannedBlocks").value(1))
                .andExpect(jsonPath("$.data.summary.totalTasks").value(1))

                .andExpect(jsonPath("$.data.items.length()").value(1))
                .andExpect(jsonPath("$.data.items[0].itemType").value("SCHEDULE"))
                .andExpect(jsonPath("$.data.items[0].itemId").value(schedule.getId().toString()))
                .andExpect(jsonPath("$.data.items[0].title").value("Morning Work"))
                .andExpect(jsonPath("$.data.items[0].subtitle").value("WORK • 1 linked task"))

                .andExpect(jsonPath("$.data.tasks[0].id").value(linkedTask.getId().toString()))
                .andExpect(jsonPath("$.data.tasks[0].linkedScheduleBlockId").value(schedule.getId().toString()));
    }

    @Test
    void unlinkedTask_shouldStillCreateStandaloneTimelineItem() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        testDataHelper.createOneTimeSchedule(
                user.getId(),
                date,
                "Morning Work",
                8,
                10
        );

        testDataHelper.createUrgentTask(
                user.getId(),
                date,
                "Review proposal"
        );

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .with(authenticatedAs(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.items.length()").value(2))
                .andExpect(jsonPath("$.data.items[0].itemType").value("SCHEDULE"))
                .andExpect(jsonPath("$.data.items[1].itemType").value("TASK"));
    }

    @Test
    void linkedTask_shouldCreateStandaloneTimelineItemWhenLinkedScheduleDoesNotOccurThatDay() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate scheduleDate = LocalDate.of(2026, 4, 22);
        LocalDate taskDate = LocalDate.of(2026, 4, 23);

        var schedule = testDataHelper.createOneTimeSchedule(
                user.getId(),
                scheduleDate,
                "One-time Wednesday Work",
                8,
                10
        );

        testDataHelper.createUrgentTaskLinkedToSchedule(
                user.getId(),
                taskDate,
                "Review proposal on Thursday",
                schedule.getId()
        );

        mockMvc.perform(get("/api/v1/timeline/me/day")
                        .with(authenticatedAs(user))
                        .param("date", taskDate.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.schedules.length()").value(0))
                .andExpect(jsonPath("$.data.tasks.length()").value(1))
                .andExpect(jsonPath("$.data.items.length()").value(1))
                .andExpect(jsonPath("$.data.items[0].itemType").value("TASK"))
                .andExpect(jsonPath("$.data.items[0].title").value("Review proposal on Thursday"));
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