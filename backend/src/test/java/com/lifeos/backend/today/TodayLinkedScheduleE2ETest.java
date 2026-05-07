package com.lifeos.backend.today;

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

class TodayLinkedScheduleE2ETest extends BaseE2ETest {

    @Test
    void linkedTopTask_shouldBeSuppressedWhenCurrentScheduleAlreadyRepresentsIt() throws Exception {
        User user = testDataHelper.createUser();

        LocalDate date = LocalDate.of(2026, 4, 22);

        var schedule = testDataHelper.createOneTimeSchedule(
                user.getId(),
                date,
                "Morning Work",
                8,
                10
        );

        testDataHelper.createUrgentTaskLinkedToSchedule(
                user.getId(),
                date,
                "Review proposal",
                schedule.getId()
        );

        mockMvc.perform(get("/api/v1/today/me")
                        .with(authenticatedAs(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.currentScheduleBlock").exists())
                .andExpect(jsonPath("$.data.currentScheduleBlock.scheduleBlockId").value(schedule.getId().toString()))
                .andExpect(jsonPath("$.data.currentScheduleBlock.title").value("Morning Work"))

                .andExpect(jsonPath("$.data.topActiveTask").doesNotExist())

                .andExpect(jsonPath("$.data.timeline.tasks.length()").value(1))
                .andExpect(jsonPath("$.data.timeline.schedules.length()").value(1))
                .andExpect(jsonPath("$.data.timeline.items.length()").value(1))
                .andExpect(jsonPath("$.data.timeline.items[0].itemType").value("SCHEDULE"));
    }

    @Test
    void unlinkedTopTask_shouldStillAppearBesideCurrentSchedule() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var schedule = testDataHelper.createOneTimeSchedule(
                user.getId(),
                date,
                "Morning Work",
                8,
                10
        );

        var task = testDataHelper.createUrgentTask(
                user.getId(),
                date,
                "Standalone proposal review"
        );

        mockMvc.perform(get("/api/v1/today/me")
                        .with(authenticatedAs(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.currentScheduleBlock").exists())
                .andExpect(jsonPath("$.data.currentScheduleBlock.scheduleBlockId").value(schedule.getId().toString()))

                .andExpect(jsonPath("$.data.topActiveTask").exists())
                .andExpect(jsonPath("$.data.topActiveTask.id").value(task.getId().toString()))
                .andExpect(jsonPath("$.data.topActiveTask.title").value("Standalone proposal review"))

                .andExpect(jsonPath("$.data.timeline.items.length()").value(2))
                .andExpect(jsonPath("$.data.timeline.items[0].itemType").value("SCHEDULE"))
                .andExpect(jsonPath("$.data.timeline.items[1].itemType").value("TASK"));
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