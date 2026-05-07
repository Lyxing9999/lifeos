package com.lifeos.backend.task;

import com.lifeos.backend.auth.domain.LifeOsPrincipal;
import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TaskReopenE2ETest extends BaseE2ETest {

        @Test
        void reopenTask_shouldMoveCompletedTaskBackToTodo() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                var task = testDataHelper.createUrgentTask(
                                user.getId(),
                                date,
                                "Reopen me");

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(post("/api/v1/tasks/{taskId}/reopen", task.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.id").value(task.getId().toString()))
                                .andExpect(jsonPath("$.data.title").value("Reopen me"))
                                .andExpect(jsonPath("$.data.status").value("TODO"));
        }

        @Test
        void reopenTask_shouldBeSafeWhenTaskIsAlreadyTodo() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                var task = testDataHelper.createUrgentTask(
                                user.getId(),
                                date,
                                "Already open");

                mockMvc.perform(post("/api/v1/tasks/{taskId}/reopen", task.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.id").value(task.getId().toString()))
                                .andExpect(jsonPath("$.data.status").value("TODO"));
        }

        @Test
        void reopenTask_shouldReturnClientErrorForUnknownTask() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                mockMvc.perform(post("/api/v1/tasks/{taskId}/reopen", UUID.randomUUID())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().is4xxClientError());
        }

        @Test
        void reopenTask_shouldAllowTaskToBeCompletedAgainAfterReopen() throws Exception {
                User user = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                var task = testDataHelper.createUrgentTask(
                                user.getId(),
                                date,
                                "Complete again");

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(post("/api/v1/tasks/{taskId}/reopen", task.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.data.status").value("TODO"));

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                                .header("Authorization", authTestHelper.bearer(user))
                                .param("date", date.toString()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.success").value(true))
                                .andExpect(jsonPath("$.data.id").value(task.getId().toString()))
                                .andExpect(jsonPath("$.data.status").value("COMPLETED"));
        }

        @Test
        void reopenTask_shouldNotAllowAnotherUserToReopenTask() throws Exception {
                User owner = testDataHelper.createUser();
                User otherUser = testDataHelper.createUser();
                LocalDate date = LocalDate.of(2026, 4, 22);

                var task = testDataHelper.createUrgentTask(
                                owner.getId(),
                                date,
                                "Private task");

                mockMvc.perform(post("/api/v1/tasks/{taskId}/complete", task.getId())
                                .header("Authorization", authTestHelper.bearer(owner))
                                .param("date", date.toString()))
                                .andExpect(status().isOk());

                mockMvc.perform(post("/api/v1/tasks/{taskId}/reopen", task.getId())
                                .header("Authorization", authTestHelper.bearer(otherUser))
                                .param("date", date.toString()))
                                .andExpect(status().is4xxClientError());
        }

        private RequestPostProcessor authenticatedAs(User user) {
                LifeOsPrincipal principal = new LifeOsPrincipal(
                                user.getId(),
                                user.getEmail());

                UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(
                                principal,
                                null,
                                List.of());

                return authentication(token);
        }
}