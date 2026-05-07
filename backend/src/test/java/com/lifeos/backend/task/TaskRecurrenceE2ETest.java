package com.lifeos.backend.task;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Set;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * PRODUCTION-GRADE RECURRENCE TEST SUITE
 * Ensures tasks appear correctly based on local date rules regardless of UTC shifts.
 */
class TaskRecurrenceE2ETest extends BaseE2ETest {

        @Test
        @DisplayName("Should include all matching recurring tasks on a specific day")
        void recurrence_shouldIncludeMatchingBlocksOnMatchingDay() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22); // Wednesday

                createTask(user, "Daily task", TaskMode.DAILY, TaskRecurrenceType.DAILY, date, null, null);
                createTask(user, "Weekly task", TaskMode.STANDARD, TaskRecurrenceType.WEEKLY, date, null, null);
                createTask(user, "Custom task", TaskMode.STANDARD, TaskRecurrenceType.CUSTOM_WEEKLY, date, null, "WEDNESDAY");
                createTask(user, "Monthly task", TaskMode.STANDARD, TaskRecurrenceType.MONTHLY, date, null, null);

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString())
                                .param("filter", "DUE")) // Use DUE to filter out unrelated noise
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data", hasSize(4)));
        }

        @Test
        @DisplayName("Daily tasks should persist on future dates")
        void dailyTask_shouldAppearEveryLocalDayFromStartDate() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate startDate = LocalDate.of(2026, 4, 22);
                LocalDate nextDate = LocalDate.of(2026, 4, 23);

                createTask(user, "Daily review", TaskMode.DAILY, TaskRecurrenceType.DAILY, startDate, null, null);

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", nextDate.toString())
                                .param("filter", "DUE"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data[0].title").value("Daily review"));
        }

        @Test
        @DisplayName("Weekly tasks should only occur on the same day of the week")
        void weeklyTask_shouldAppearOnlyOnSameWeekdayAsStartDate() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate startDate = LocalDate.of(2026, 4, 22); // Wednesday
                LocalDate thursday = LocalDate.of(2026, 4, 23);

                createTask(user, "Weekly review", TaskMode.STANDARD, TaskRecurrenceType.WEEKLY, startDate, null, null);

                // Verify it does NOT occur on Thursday (Filter DUE hides overdue from previous day)
                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", thursday.toString())
                                .param("filter", "DUE"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data", hasSize(0)));
        }

        @Test
        @DisplayName("Custom weekly tasks should match exact requested days")
        void customWeeklyTask_shouldAppearOnSelectedWeekdaysOnly() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate startDate = LocalDate.of(2026, 4, 22); // Wed
                LocalDate thursday = LocalDate.of(2026, 4, 23);
                LocalDate friday = LocalDate.of(2026, 4, 24);

                createTask(user, "Workout", TaskMode.STANDARD, TaskRecurrenceType.CUSTOM_WEEKLY, startDate, null, "WEDNESDAY,FRIDAY");

                // Should appear Friday
                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", friday.toString())
                                .param("filter", "DUE"))
                        .andExpect(jsonPath("$.data[0].title").value("Workout"));

                // Should NOT appear Thursday
                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", thursday.toString())
                                .param("filter", "DUE"))
                        .andExpect(jsonPath("$.data", hasSize(0)));
        }

        @Test
        @DisplayName("Monthly tasks should only appear on the same numerical day")
        void monthlyTask_shouldAppearOnlyOnSameDayOfMonth() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate startDate = LocalDate.of(2026, 4, 22);
                LocalDate nextMonthDifferentDay = LocalDate.of(2026, 5, 23);

                createTask(user, "Monthly review", TaskMode.STANDARD, TaskRecurrenceType.MONTHLY, startDate, null, null);

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", nextMonthDifferentDay.toString())
                                .param("filter", "DUE"))
                        .andExpect(jsonPath("$.data", hasSize(0)));
        }

        @Test
        @DisplayName("Recurrence should honor the end date")
        void recurrence_shouldStopAfterEndDate() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate startDate = LocalDate.of(2026, 4, 22);
                LocalDate endDate = LocalDate.of(2026, 4, 24);
                LocalDate afterEndDate = LocalDate.of(2026, 4, 25);

                createTask(user, "Limited daily", TaskMode.DAILY, TaskRecurrenceType.DAILY, startDate, endDate, null);

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", afterEndDate.toString())
                                .param("filter", "DUE"))
                        .andExpect(jsonPath("$.data", hasSize(0)));
        }

        @Test
        @DisplayName("Local dates must be stable regardless of server UTC time")
        void khLocalDate_shouldUseRequestedDateNotUtcConversion() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate khDate = LocalDate.of(2026, 4, 22);

                CreateTaskRequest request = new CreateTaskRequest();
                request.setTitle("KH late night task");
                request.setTaskMode(TaskMode.STANDARD);
                request.setPriority(TaskPriority.MEDIUM);
                request.setDueDate(khDate);
                request.setDueDateTime(khDate.atTime(23, 30));
                request.setRecurrenceType(TaskRecurrenceType.NONE);

                mockMvc.perform(post("/api/v1/tasks")
                                .header("Authorization", authTestHelper.bearer(user))
                                .contentType(json)
                                .content(toJson(request)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.dueDateTime").value("2026-04-22T23:30:00"));

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", "2026-04-22")
                                .param("filter", "DUE"))
                        .andExpect(jsonPath("$.data[0].title").value("KH late night task"));
        }

        @Test
        @DisplayName("US local input should remain exact to avoid day-shifts")
        void usLocalDateInput_shouldRemainExactLocalDateAndTime() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate usLocalDate = LocalDate.of(2026, 4, 21);

                CreateTaskRequest request = new CreateTaskRequest();
                request.setTitle("US evening task");
                request.setTaskMode(TaskMode.STANDARD);
                request.setPriority(TaskPriority.MEDIUM);
                request.setDueDate(usLocalDate);
                request.setDueDateTime(usLocalDate.atTime(20, 30));
                request.setRecurrenceType(TaskRecurrenceType.NONE);

                mockMvc.perform(post("/api/v1/tasks")
                                .header("Authorization", authTestHelper.bearer(user))
                                .contentType(json)
                                .content(toJson(request)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.dueDateTime").value("2026-04-21T20:30:00"));

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", "2026-04-21")
                                .param("filter", "DUE"))
                        .andExpect(jsonPath("$.data[0].title").value("US evening task"));
        }

        private void createTask(
                User user,
                String title,
                TaskMode mode,
                TaskRecurrenceType recurrenceType,
                LocalDate recurrenceStartDate,
                LocalDate recurrenceEndDate,
                String recurrenceDaysOfWeek) throws Exception {
                CreateTaskRequest request = new CreateTaskRequest();
                request.setTitle(title);
                request.setDescription(title + " description");
                request.setCategory("TEST");
                request.setTaskMode(mode);
                request.setPriority(TaskPriority.MEDIUM);
                request.setRecurrenceType(recurrenceType);
                request.setRecurrenceStartDate(recurrenceStartDate);
                request.setRecurrenceEndDate(recurrenceEndDate);
                request.setRecurrenceDaysOfWeek(recurrenceDaysOfWeek);
                request.setTags(Set.of("recurrence", "test"));

                mockMvc.perform(post("/api/v1/tasks")
                                .header("Authorization", authTestHelper.bearer(user))
                                .contentType(json)
                                .content(toJson(request)))
                        .andExpect(status().isOk());
        }
}