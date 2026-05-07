package com.lifeos.backend.schedule;

import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.request.UpdateScheduleBlockRequest;
import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ScheduleControllerE2ETest extends BaseE2ETest {

    @Test
    void createSchedule_shouldReturnCreatedBlockOwnedByMe() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 4, 22);

        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setTitle("Morning Work");
        request.setDescription("Deep work block");
        request.setType(ScheduleBlockType.WORK);
        request.setStartTime(LocalTime.of(8, 0));
        request.setEndTime(LocalTime.of(10, 0));
        request.setRecurrenceType(ScheduleRecurrenceType.NONE);
        request.setRecurrenceStartDate(date);

        mockMvc.perform(post("/api/v1/schedules")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                .andExpect(jsonPath("$.data.title").value("Morning Work"))
                .andExpect(jsonPath("$.data.active").value(true));
    }

    @Test
    void updateSchedule_shouldReturnUpdatedBlock() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.now();
        var block = testDataHelper.createOneTimeSchedule(user.getId(), date, "Old Title", 8, 9);

        UpdateScheduleBlockRequest request = new UpdateScheduleBlockRequest();
        request.setTitle("Updated Title");
        request.setStartTime(LocalTime.of(10, 0));
        request.setEndTime(LocalTime.of(11, 0));

        mockMvc.perform(patch("/api/v1/schedules/{id}", block.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.title").value("Updated Title"))
                .andExpect(jsonPath("$.data.startTime").value("10:00:00"));
    }

    @Test
    void getSurfaces_shouldReturnActiveAndInactiveBlocks() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.now();

        testDataHelper.createOneTimeSchedule(user.getId(), date, "Active Block", 8, 9);
        var inactiveBlock = testDataHelper.createOneTimeSchedule(user.getId(), date, "Inactive Block", 9, 10);

        // Deactivate one manually (Inactive)
        mockMvc.perform(post("/api/v1/schedules/{id}/deactivate", inactiveBlock.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(1)))
                .andExpect(jsonPath("$.data.activeBlocks[0].title").value("Active Block"))
                .andExpect(jsonPath("$.data.inactiveBlocks", hasSize(1)))
                .andExpect(jsonPath("$.data.inactiveBlocks[0].title").value("Inactive Block"));
    }

    @Test
    void getMySelectOptions_shouldReturnOnlyEffectiveActiveOptions() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate today = LocalDate.now();

        var active = testDataHelper.createOneTimeSchedule(user.getId(), today, "Work Block", 8, 9);
        var inactive = testDataHelper.createDailySchedule(user.getId(), today, "Inactive Block", 9, 10);

        mockMvc.perform(post("/api/v1/schedules/{id}/deactivate", inactive.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/schedules/me/select-options")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", today.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(1)))
                .andExpect(jsonPath("$.data[0].scheduleBlockId").value(active.getId().toString()));
    }

    @Test
    void deactivate_shouldMoveBlockToInactiveSurface() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.now();
        var block = testDataHelper.createOneTimeSchedule(user.getId(), date, "Toggle Me", 8, 9);

        // Deactivate
        mockMvc.perform(post("/api/v1/schedules/{id}/deactivate", block.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(false));

        // Verify Surface - Should be in inactiveBlocks
        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(0)))
                .andExpect(jsonPath("$.data.inactiveBlocks", hasSize(1)));
    }

    @Test
    void activate_shouldRestoreBlockToActiveSurface() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.now();
        var block = testDataHelper.createOneTimeSchedule(user.getId(), date, "Toggle Me", 8, 9);

        mockMvc.perform(post("/api/v1/schedules/{id}/deactivate", block.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk());

        // Activate
        mockMvc.perform(post("/api/v1/schedules/{id}/activate", block.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(true));

        // Verify Surface - Should return to activeBlocks
        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(jsonPath("$.data.activeBlocks", hasSize(1)));
    }

    @Test
    void delete_shouldHardDeleteAndClearFromSurfaces() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.now();
        var block = testDataHelper.createOneTimeSchedule(user.getId(), date, "Delete Me", 8, 9);

        mockMvc.perform(delete("/api/v1/schedules/{id}", block.getId())
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/schedules/me/surfaces")
                        .header("Authorization", authTestHelper.bearer(user))
                        .param("date", date.toString()))
                .andExpect(jsonPath("$.data.counts.total").value(0));
    }

    @Test
    void createSchedule_withInvalidTimeRange_shouldReturnBadRequest() throws Exception {
        User user = testDataHelper.createUser();
        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setTitle("Invalid Block");
        request.setStartTime(LocalTime.of(10, 0));
        request.setEndTime(LocalTime.of(9, 0));
        request.setRecurrenceStartDate(LocalDate.now());

        mockMvc.perform(post("/api/v1/schedules")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createSchedule_customWeeklyWithoutDays_shouldReturnBadRequest() throws Exception {
        User user = testDataHelper.createUser();
        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setTitle("No Days");
        request.setStartTime(LocalTime.of(8, 0));
        request.setEndTime(LocalTime.of(9, 0));
        request.setRecurrenceType(ScheduleRecurrenceType.CUSTOM_WEEKLY);
        request.setRecurrenceDaysOfWeek("");
        request.setRecurrenceStartDate(LocalDate.now());

        mockMvc.perform(post("/api/v1/schedules")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createSchedule_endDateBeforeStartDate_shouldReturnBadRequest() throws Exception {
        User user = testDataHelper.createUser();
        CreateScheduleBlockRequest request = new CreateScheduleBlockRequest();
        request.setTitle("Bad Dates");
        request.setStartTime(LocalTime.of(8, 0));
        request.setEndTime(LocalTime.of(9, 0));
        request.setRecurrenceStartDate(LocalDate.of(2026, 4, 22));
        request.setRecurrenceEndDate(LocalDate.of(2026, 4, 21));

        mockMvc.perform(post("/api/v1/schedules")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest());
    }
}