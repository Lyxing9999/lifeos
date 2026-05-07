package com.lifeos.backend.timeline;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TimelineControllerE2ETest extends BaseE2ETest {

        @Test
        void getDay_withAuth_shouldReturnMergedTaskAndScheduleItems() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22); // Wednesday

                testDataHelper.createOneTimeSchedule(user.getId(), date, "One-time Wednesday Block", 8, 9);
                testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
                testDataHelper.createWeeklySchedule(user.getId(), date, "Weekly Wednesday Review", 10, 11);
                testDataHelper.createCustomWeeklySchedule(user.getId(), date, "Custom Wednesday Gym", 18, 19,
                                "WEDNESDAY");

                testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");
                testDataHelper.createProgressTask(user.getId(), date, "Progress task", 60);
                testDataHelper.createDailyTask(user.getId(), date, "Daily task");

                mockMvc.perform(get("/api/v1/timeline/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                                .andExpect(jsonPath("$.data.date").value("2026-04-22"))
                                .andExpect(jsonPath("$.data.items").isArray())
                                .andExpect(jsonPath("$.data.items.length()").value(7))
                                .andExpect(jsonPath("$.data.schedules.length()").value(4))
                                .andExpect(jsonPath("$.data.tasks.length()").value(3))
                                .andExpect(jsonPath("$.data.summary.totalPlannedBlocks").value(4))
                                .andExpect(jsonPath("$.data.summary.totalTasks").value(3));
        }

        @Test
        void getDay_withAuth_shouldIncludeScheduleAndTaskItemTypes() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                testDataHelper.createDailySchedule(user.getId(), date, "Daily Planning Block", 9, 10);
                testDataHelper.createUrgentTask(user.getId(), date, "Urgent task");

                mockMvc.perform(get("/api/v1/timeline/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.items").isArray())
                                .andExpect(jsonPath("$.data.items.length()").value(2))
                                .andExpect(jsonPath("$.data.items[0].itemType").value("SCHEDULE"))
                                .andExpect(jsonPath("$.data.items[0].title").value("Daily Planning Block"))
                                .andExpect(jsonPath("$.data.items[1].itemType").value("TASK"))
                                .andExpect(jsonPath("$.data.items[1].title").value("Urgent task"));
        }

        @Test
        void getDay_withAuth_shouldRespectCustomWeeklyAndNotLeakToNonMatchingDay() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate wednesday = LocalDate.of(2026, 4, 22);
                LocalDate thursday = LocalDate.of(2026, 4, 23);

                testDataHelper.createCustomWeeklySchedule(
                                user.getId(),
                                wednesday,
                                "Custom Wednesday Gym",
                                18,
                                19,
                                "WEDNESDAY");

                mockMvc.perform(get("/api/v1/timeline/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", wednesday.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.items.length()").value(1))
                                .andExpect(jsonPath("$.data.items[0].itemType").value("SCHEDULE"))
                                .andExpect(jsonPath("$.data.items[0].title").value("Custom Wednesday Gym"));

                mockMvc.perform(get("/api/v1/timeline/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", thursday.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.items.length()").value(0))
                                .andExpect(jsonPath("$.data.schedules.length()").value(0));
        }

        @Test
        void taskWithoutDueDateAndWithoutRepeat_shouldNotAppearInTimelineDay() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                CreateTaskRequest request = new CreateTaskRequest();
                request.setTitle("Inbox-only task");
                request.setDescription("No due date and no repeat");
                request.setCategory("WORK");
                request.setTaskMode(TaskMode.STANDARD);
                request.setPriority(TaskPriority.MEDIUM);
                request.setDueDate(null);
                request.setDueDateTime(null);
                request.setRecurrenceType(TaskRecurrenceType.NONE);
                // Simulate legacy/defaulted recurrence start while repeat is OFF.
                request.setRecurrenceStartDate(date);

                mockMvc.perform(post("/api/v1/tasks")
                                .header("Authorization", authTestHelper.bearer(user))
                                .contentType(json)
                                .content(toJson(request)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true));

                mockMvc.perform(get("/api/v1/timeline/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.tasks[?(@.title=='Inbox-only task')]").doesNotExist())
                                .andExpect(jsonPath("$.data.items[?(@.title=='Inbox-only task')]").doesNotExist());
        }

        @Test
        void getDay_withoutAuth_shouldReturnUnauthorized() throws Exception {
                LocalDate date = LocalDate.of(2026, 4, 22);

                mockMvc.perform(get("/api/v1/timeline/me/day")
                                .param("date", date.toString()))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void deprecatedTimelinePath_shouldIgnorePathUserIdAndUseAuthenticatedUser() throws Exception {
                User realUser = testDataHelper.createUser();
                User otherUser = testDataHelper.createUser();

                LocalDate date = LocalDate.of(2026, 4, 22);

                testDataHelper.createUrgentTask(realUser.getId(), date, "Real user task");
                testDataHelper.createUrgentTask(otherUser.getId(), date, "Other user task");

                mockMvc.perform(get("/api/v1/timeline/user/{userId}/day", otherUser.getId())
                                .header("Authorization", authTestHelper.bearer(realUser))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.userId").value(realUser.getId().toString()))
                                .andExpect(jsonPath("$.data.tasks[?(@.title=='Real user task')]").exists())
                                .andExpect(jsonPath("$.data.tasks[?(@.title=='Other user task')]").doesNotExist());
        }
}