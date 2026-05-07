package com.lifeos.backend.timeline.application;

import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.timeline.dto.TimelineItemResponse;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

@Component
public class TaskTimelineItemMapper {

    public Optional<TimelineItemResponse> toTimelineItem(
            TaskResponse task,
            ZoneId zoneId,
            LocalDate requestedDate
    ) {
        if (task == null || requestedDate == null) {
            return Optional.empty();
        }

        LocalDateTime effectiveDateTime = resolveEffectiveDateTime(task, zoneId, requestedDate);

        if (effectiveDateTime == null) {
            return Optional.empty();
        }

        if (!effectiveDateTime.toLocalDate().equals(requestedDate)) {
            return Optional.empty();
        }

        return Optional.of(
                TimelineItemResponse.builder()
                        .itemType("TASK")
                        .itemId(task.getId())
                        .title(task.getTitle())
                        .subtitle(buildSubtitle(task))
                        .startDateTime(effectiveDateTime)
                        .endDateTime(null)
                        .badge("Task")
                        .status(task.getStatus() != null ? task.getStatus().name() : null)
                        .build()
        );
    }

    private LocalDateTime resolveEffectiveDateTime(
            TaskResponse task,
            ZoneId zoneId,
            LocalDate requestedDate
    ) {
        if (task.getDueDateTime() != null) {
            return task.getDueDateTime();
        }

        if (task.getCompletedAt() != null) {
            return task.getCompletedAt().atZone(zoneId).toLocalDateTime();
        }

        if (task.getDueDate() != null) {
            return task.getDueDate().atStartOfDay();
        }

        if (isRecurring(task)) {
            return requestedDate.atStartOfDay();
        }

        return null;
    }

    private boolean isRecurring(TaskResponse task) {
        return task.getRecurrenceType() != null
                && task.getRecurrenceType() != TaskRecurrenceType.NONE;
    }

    private String buildSubtitle(TaskResponse task) {
        String mode = task.getTaskMode() != null ? task.getTaskMode().name() : "TASK";
        String priority = task.getPriority() != null ? task.getPriority().name() : "MEDIUM";

        String firstTag = null;
        if (task.getTags() != null && !task.getTags().isEmpty()) {
            firstTag = task.getTags().stream()
                    .map(tag -> tag.getName())
                    .filter(name -> name != null && !name.isBlank())
                    .sorted(Comparator.naturalOrder())
                    .findFirst()
                    .orElse(null);
        }

        List<String> parts = new ArrayList<>();
        parts.add(mode);
        parts.add(priority);

        if (firstTag != null) {
            parts.add("#" + firstTag);
        }

        return String.join(" • ", parts);
    }
}