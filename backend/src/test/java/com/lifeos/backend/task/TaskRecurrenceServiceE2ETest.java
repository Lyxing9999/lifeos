package com.lifeos.backend.task;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.application.TaskCommandService;
import com.lifeos.backend.task.application.TaskQueryService;
import com.lifeos.backend.task.domain.enums.TaskFilterType;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class TaskRecurrenceServiceE2ETest extends BaseE2ETest {

    @Autowired
    private TaskCommandService taskCommandService;

    @Autowired
    private TaskQueryService taskQueryService;

    @Test
    void weeklyTask_shouldBeRelevantOnNextSameWeekdayThroughService() {
        User user = testDataHelper.createUser();

        LocalDate startDate = LocalDate.of(2026, 4, 22); // Wednesday
        LocalDate nextWednesday = LocalDate.of(2026, 4, 29);
        LocalDate thursday = LocalDate.of(2026, 4, 23);

        CreateTaskRequest request = new CreateTaskRequest();
        request.setUserId(user.getId());
        request.setTitle("Weekly service debug");
        request.setDescription("Debug weekly recurrence");
        request.setCategory("TEST");
        request.setTaskMode(TaskMode.STANDARD);
        request.setPriority(TaskPriority.MEDIUM);
        request.setDueDate(null);
        request.setDueDateTime(null);
        request.setProgressPercent(null);
        request.setRecurrenceType(TaskRecurrenceType.WEEKLY);
        request.setRecurrenceStartDate(startDate);
        request.setRecurrenceEndDate(null);
        request.setRecurrenceDaysOfWeek(null);
        request.setTags(null);

        TaskResponse created = taskCommandService.create(request);

        assertEquals("Weekly service debug", created.getTitle());
        assertEquals(TaskRecurrenceType.WEEKLY, created.getRecurrenceType());
        assertEquals(startDate, created.getRecurrenceStartDate());

        List<TaskResponse> nextWednesdayTasks =
                taskQueryService.getRelevantTasksByUserAndDay(user.getId(), nextWednesday, TaskFilterType.ALL);

        assertTrue(
                nextWednesdayTasks.stream().anyMatch(t -> "Weekly service debug".equals(t.getTitle())),
                "Expected weekly task on next Wednesday, got: "
                        + nextWednesdayTasks.stream().map(TaskResponse::getTitle).toList()
        );

        List<TaskResponse> thursdayTasks =
                taskQueryService.getRelevantTasksByUserAndDay(user.getId(), thursday, TaskFilterType.ALL);

        assertFalse(
                thursdayTasks.stream().anyMatch(t -> "Weekly service debug".equals(t.getTitle())),
                "Did not expect weekly task on Thursday, got: "
                        + thursdayTasks.stream().map(TaskResponse::getTitle).toList()
        );
    }
}