package com.lifeos.backend.task.infrastructure;

import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.api.response.TaskTagResponse;
import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.TaskTag;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class TaskMapper {

    public Task toEntity(CreateTaskRequest request) {
        Task task = new Task();
        task.setUserId(request.getUserId());
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        task.setCategory(request.getCategory());
        task.setTaskMode(request.getTaskMode());
        task.setPriority(request.getPriority());
        task.setStatus(TaskStatus.TODO);
        task.setDueDate(request.getDueDate());
        task.setDueDateTime(request.getDueDateTime());
        task.setProgressPercent(request.getProgressPercent());
        task.setDoneClearedAt(null);
        task.setArchived(false);
        task.setArchivedAt(null);
        task.setPaused(false);
        task.setPausedAt(null);
        task.setPauseUntil(null);
        task.setAchievedDate(null);

        task.setLinkedScheduleBlockId(request.getLinkedScheduleBlockId());
        task.setRecurrenceRule(new TaskRecurrenceRule(
                request.getRecurrenceType(),
                request.getRecurrenceStartDate(),
                request.getRecurrenceEndDate(),
                request.getRecurrenceDaysOfWeek()
        ));
        task.clearAndReplaceTags(request.getTags());
        return task;
    }

    public TaskResponse toResponse(Task task) {
        List<TaskTagResponse> tagResponses = task.getTags() != null
                ? task.getTags().stream()
                .map(this::toTagResponse)
                .toList()
                : List.of();

        return TaskResponse.builder()
                .id(task.getId())
                .userId(task.getUserId())
                .title(task.getTitle())
                .description(task.getDescription())
                .category(task.getCategory())
                .status(task.getStatus())
                .taskMode(task.getTaskMode())
                .priority(task.getPriority())
                .dueDate(task.getDueDate())
                .dueDateTime(task.getDueDateTime())
                .progressPercent(task.getProgressPercent())
                .startedAt(task.getStartedAt())
                .completedAt(task.getCompletedAt())
                .achievedDate(task.getAchievedDate())
                .doneClearedAt(task.getDoneClearedAt())
                .archived(task.getArchived())
                .paused(task.getPaused())
                .pausedAt(task.getPausedAt())
                .pauseUntil(task.getPauseUntil())
                .recurrenceType(task.getRecurrenceRule() != null ? task.getRecurrenceRule().getType() : null)
                .recurrenceStartDate(task.getRecurrenceRule() != null ? task.getRecurrenceRule().getStartDate() : null)
                .recurrenceEndDate(task.getRecurrenceRule() != null ? task.getRecurrenceRule().getEndDate() : null)
                .recurrenceDaysOfWeek(task.getRecurrenceRule() != null ? task.getRecurrenceRule().getDaysOfWeek() : null)
                .linkedScheduleBlockId(task.getLinkedScheduleBlockId())
                .tags(tagResponses)
                .build();
    }

    private TaskTagResponse toTagResponse(TaskTag tag) {
        return TaskTagResponse.builder()
                .name(tag.getName())
                .build();
    }
}