package com.lifeos.backend.schedule;

import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ScheduleControllerE2ETest extends BaseE2ETest {

    @Test
    void createSchedule_shouldReturnCreatedBlock() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setUserId(user.getId());
        request.setTitle("Morning Work");
        request.setDescription("Deep work block");
        request.setType(ScheduleBlockType.WORK);
        request.setStartTime(LocalTime.of(8, 0));
        request.setEndTime(LocalTime.of(10, 0));
        request.setRecurrenceType(ScheduleRecurrenceType.NONE);
        request.setRecurrenceStartDate(date);
        request.setRecurrenceEndDate(null);
        request.setRecurrenceDaysOfWeek(null);

        mockMvc.perform(post("/api/v1/schedules")
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.title").value("Morning Work"))
                .andExpect(jsonPath("$.data.type").value("WORK"))
                .andExpect(jsonPath("$.data.recurrenceType").value("NONE"))
                .andExpect(jsonPath("$.data.recurrenceStartDate").value("2026-04-22"));
    }

    @Test
    void getSchedulesByUser_shouldReturnBlocks() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Block", 8, 9);
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Block", 9, 10);

        mockMvc.perform(get("/api/v1/schedules/user/{userId}", user.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void getOccurrencesByDay_shouldReturnOccurrences() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Block", 8, 9);
        testDataHelper.createDailySchedule(user.getId(), date, "Daily Block", 9, 10);

        mockMvc.perform(get("/api/v1/schedules/user/{userId}/day", user.getId())
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(2))
                .andExpect(jsonPath("$.data[0].occurrenceDate").value("2026-04-22"));
    }
}