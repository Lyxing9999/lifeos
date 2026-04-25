package com.lifeos.backend.summary;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;

class DailySummaryControllerE2ETest extends BaseE2ETest {

    @Test
    void generateSummary_shouldReturnFreshSummary() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var urgent = testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");

        testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Wednesday Block", 8, 9);
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
        testDataHelper.createWeeklySchedule(user.getId(), date, "Weekly Wednesday Review", 10, 11);
        testDataHelper.createCustomWeeklySchedule(user.getId(), date, "Custom Wednesday Gym", 18, 19, "WEDNESDAY");

        testDataHelper.completeTask(urgent.getId());

        mockMvc.perform(post("/api/v1/summary/user/{userId}/generate", user.getId())
                        .param("date", date.toString()))
                .andDo(print())
                .andReturn();
    }

    @Test
    void getSummary_shouldReturnPersistedSummary() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        var urgent = testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
        testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
        testDataHelper.createDailyTask(user.getId(), date, "Daily task");
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
        testDataHelper.completeTask(urgent.getId());

        mockMvc.perform(post("/api/v1/summary/user/{userId}/generate", user.getId())
                        .param("date", date.toString()))
                .andDo(print())
                .andReturn();

        mockMvc.perform(get("/api/v1/summary/user/{userId}/day", user.getId())
                        .param("date", date.toString()))
                .andDo(print())
                .andReturn();
    }
}