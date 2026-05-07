package com.lifeos.backend.task;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.task.api.request.UpdateTaskRequest;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Set;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TaskTagRegressionE2ETest extends BaseE2ETest {

    @Test
    void updateTask_withDuplicateEquivalentTags_shouldNotViolateUniqueConstraint() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createTaskWithTags(
                user.getId(),
                date,
                "Prepare production rollout",
                Set.of("production")
        );

        UpdateTaskRequest request = new UpdateTaskRequest();
        request.setTitle("Prepare production rollout");
        request.setDescription("Updated tagged task");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.STANDARD);
        request.setPriority(TaskPriority.MEDIUM);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(10, 0));
        request.setRecurrenceType(TaskRecurrenceType.NONE);

        // Regression:
        // These are equivalent after normalization and should not create duplicate rows.
        request.setTags(Set.of("production", " Production ", "PRODUCTION"));

        mockMvc.perform(patch("/api/v1/tasks/{taskId}", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(task.getId().toString()))
                .andExpect(jsonPath("$.data.tags.length()").value(1))
                .andExpect(jsonPath("$.data.tags[0].name").value("production"));
    }

    @Test
    void updateTask_replacingTags_shouldKeepExistingMatchingTagAndAddOnlyNewTags() throws Exception {
        User user = testDataHelper.createUser();
        LocalDate date = LocalDate.of(2026, 5, 1);

        var task = testDataHelper.createTaskWithTags(
                user.getId(),
                date,
                "Ship mobile task polish",
                Set.of("production", "mobile")
        );

        UpdateTaskRequest request = new UpdateTaskRequest();
        request.setTitle("Ship mobile task polish");
        request.setDescription("Updated tagged task");
        request.setCategory("WORK");
        request.setTaskMode(TaskMode.STANDARD);
        request.setPriority(TaskPriority.MEDIUM);
        request.setDueDate(date);
        request.setDueDateTime(date.atTime(11, 0));
        request.setRecurrenceType(TaskRecurrenceType.NONE);

        // Should remove "mobile", keep "production", add "release".
        request.setTags(Set.of("production", "release", " Release "));

        mockMvc.perform(patch("/api/v1/tasks/{taskId}", task.getId())
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.tags.length()").value(2))
                .andExpect(jsonPath("$.data.tags[?(@.name=='production')]").exists())
                .andExpect(jsonPath("$.data.tags[?(@.name=='release')]").exists())
                .andExpect(jsonPath("$.data.tags[?(@.name=='mobile')]").doesNotExist());
    }
}