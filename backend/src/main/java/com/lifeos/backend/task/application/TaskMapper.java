package com.lifeos.backend.task.application;

import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.api.response.TaskTagResponse;
import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.TaskTag;
import org.springframework.stereotype.Component;

import java.util.Comparator;
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
        task.setDueDate(request.getDueDate());
        task.setDueDateTime(request.getDueDateTime());
        task.setProgressPercent(request.getProgressPercent());
        task.setRecurrenceType(request.getRecurrenceType());
        task.setRecurrenceStartDate(request.getRecurrenceStartDate());
        task.setRecurrenceEndDate(request.getRecurrenceEndDate());
        task.setRecurrenceDaysOfWeek(request.getRecurrenceDaysOfWeek());
        task.setLinkedScheduleBlockId(request.getLinkedScheduleBlockId());
        task.clearAndReplaceTags(request.getTags());
        return task;
    }

    public TaskResponse toResponse(Task task) {
        List<TaskTagResponse> tags = task.getTags().stream()
                .sorted(Comparator.comparing(TaskTag::getName, String::compareToIgnoreCase))
                .map(tag -> TaskTagResponse.builder().name(tag.getName()).build())
                .toList();

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
                .archived(task.getArchived())
                .recurrenceType(task.getRecurrenceType())
                .recurrenceStartDate(task.getRecurrenceStartDate())
                .recurrenceEndDate(task.getRecurrenceEndDate())
                .recurrenceDaysOfWeek(task.getRecurrenceDaysOfWeek())
                .linkedScheduleBlockId(task.getLinkedScheduleBlockId())
                .tags(tags)
                .build();
    }
}