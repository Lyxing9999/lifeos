package com.lifeos.backend.task;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.request.UpdateTaskRequest;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Set;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TaskControllerE2ETest extends BaseE2ETest {

        @Test
        void createTask_withAuth_shouldReturnCreatedTaskOwnedByMe() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                CreateTaskRequest request = new CreateTaskRequest();
                request.setTitle("Fix DTO mismatch");
                request.setTaskMode(TaskMode.URGENT);
                request.setPriority(TaskPriority.HIGH);
                request.setDueDate(date);
                request.setDueDateTime(date.atTime(15, 0));
                request.setRecurrenceType(TaskRecurrenceType.NONE);

                mockMvc.perform(post("/api/v1/tasks")
                                .header("Authorization", authTestHelper.bearer(user))
                                .contentType(json)
                                .content(toJson(request)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.success").value(true))
                        .andExpect(jsonPath("$.data.userId").value(user.getId().toString()))
                        .andExpect(jsonPath("$.data.title").value("Fix DTO mismatch"));
        }

        @Test
        void createTask_shouldIgnoreUserIdInRequestAndUseAuthenticatedUser() throws Exception {
                User me = testDataHelper.createUser();
                User other = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                CreateTaskRequest request = new CreateTaskRequest();
                request.setUserId(other.getId());
                request.setTitle("Should belong to me");
                request.setDueDate(date);
                request.setRecurrenceType(TaskRecurrenceType.NONE);

                mockMvc.perform(post("/api/v1/tasks")
                                .header("Authorization", authTestHelper.bearer(me))
                                .contentType(json)
                                .content(toJson(request)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.userId").value(me.getId().toString()));
        }

        @Test
        void getMyTasks_shouldReturnOnlyAuthenticatedUsersTasks() throws Exception {
                User me = testDataHelper.createUser();
                User other = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                testDataHelper.createUrgentTask(me.getId(), date, "My task");
                testDataHelper.createUrgentTask(other.getId(), date, "Other task");

                mockMvc.perform(get("/api/v1/tasks/me")
                                .header("Authorization", authTestHelper.bearer(me))
                                .param("filter", "ALL"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.length()").value(1))
                        .andExpect(jsonPath("$.data[0].title").value("My task"));
        }

        @Test
        void getMyTasksForDay_shouldReturnRelevantTasksForAuthenticatedUserOnly() throws Exception {
                User me = testDataHelper.createUser();
                User other = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                testDataHelper.createUrgentTask(me.getId(), date, "My urgent task");
                testDataHelper.createUrgentTask(other.getId(), date, "Other user task");

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(me))
                                .param("date", date.toString())
                                .param("filter", "ALL"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.length()").value(1))
                        .andExpect(jsonPath("$.data[0].title").value("My urgent task"));
        }

        @Test
        void completeEndpoint_shouldMarkTaskCompleted() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);
                var task = testDataHelper.createUrgentTask(user.getId(), date, "Complete me");

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                                .header("Authorization", authTestHelper.bearer(user)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.status").value("COMPLETED"));
        }

        @Test
        void archiveTask_shouldHideTaskFromMyDayList() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);
                var task = testDataHelper.createUrgentTask(user.getId(), date, "Archive me");

                mockMvc.perform(post("/api/v1/tasks/{taskId}/archive", task.getId())
                                .header("Authorization", authTestHelper.bearer(user)))
                        .andExpect(status().isOk());

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString())
                                .param("filter", "ALL"))
                        .andExpect(jsonPath("$.data.length()").value(0));
        }

        @Test
        void deleteTask_shouldRemoveTaskCompletely() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);
                var task = testDataHelper.createUrgentTask(user.getId(), date, "Delete me");

                mockMvc.perform(delete("/api/v1/tasks/{taskId}", task.getId())
                                .header("Authorization", authTestHelper.bearer(user)))
                        .andExpect(status().isOk());

                mockMvc.perform(get("/api/v1/tasks/me/day")
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                        .andExpect(jsonPath("$.data.length()").value(0));
        }

        @Test
        void updateTask_shouldModifyMutableFields() throws Exception {
                User user = testDataHelper.createUser();
                var task = testDataHelper.createUrgentTask(user.getId(), LocalDate.now(), "Old");

                UpdateTaskRequest request = new UpdateTaskRequest();
                request.setTitle("New");

                mockMvc.perform(patch("/api/v1/tasks/{taskId}", task.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .contentType(json)
                                .content(toJson(request)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.title").value("New"));
        }

        @Test
        void createTask_withDueDateAndDailyRecurrence_shouldUseDueDateAsRecurrenceStart() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 5, 3);

                CreateTaskRequest request = new CreateTaskRequest();
                request.setTitle("Daily reading");
                request.setTaskMode(TaskMode.DAILY);
                request.setDueDate(date);
                request.setRecurrenceType(TaskRecurrenceType.DAILY);

                mockMvc.perform(post("/api/v1/tasks")
                                .header("Authorization", authTestHelper.bearer(user))
                                .contentType(json)
                                .content(toJson(request)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.recurrenceStartDate").value(date.toString()))
                        .andExpect(jsonPath("$.data.dueDate").doesNotExist());
        }
}