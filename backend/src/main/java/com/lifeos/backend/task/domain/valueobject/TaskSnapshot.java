package com.lifeos.backend.task.domain.valueobject;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Immutable-style snapshot of task data at a moment in time.
 *
 * Useful for:
 * - mutation history
 * - timeline projection
 * - AI summary snapshot
 * - audit/debugging
 */
@Embeddable
@Getter
@Setter
public class TaskSnapshot {

    @Column(name = "snapshot_template_id")
    private UUID templateId;

    @Column(name = "snapshot_instance_id")
    private UUID instanceId;

    @Column(name = "snapshot_title", length = 300)
    private String title;

    @Column(name = "snapshot_description", length = 4000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "snapshot_status", length = 40)
    private TaskInstanceStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "snapshot_priority", length = 40)
    private TaskPriority priority;

    @Column(name = "snapshot_category", length = 100)
    private String category;

    @Column(name = "snapshot_occurrence_date")
    private LocalDate occurrenceDate;

    @Column(name = "snapshot_scheduled_date")
    private LocalDate scheduledDate;

    @Column(name = "snapshot_due_date_time")
    private LocalDateTime dueDateTime;

    @Column(name = "snapshot_linked_schedule_block_id")
    private UUID linkedScheduleBlockId;

    public TaskSnapshot() {
    }

    public static TaskSnapshot fromTemplate(TaskTemplate template) {
        if (template == null) {
            return null;
        }

        TaskSnapshot snapshot = new TaskSnapshot();
        snapshot.setTemplateId(template.getId());
        snapshot.setTitle(template.getTitle());
        snapshot.setDescription(template.getDescription());
        snapshot.setPriority(template.getPriority());
        snapshot.setCategory(template.getCategory());
        snapshot.setLinkedScheduleBlockId(template.getLinkedScheduleBlockId());
        return snapshot;
    }

    public static TaskSnapshot fromInstance(TaskInstance instance) {
        if (instance == null) {
            return null;
        }

        TaskSnapshot snapshot = new TaskSnapshot();
        snapshot.setTemplateId(instance.getTemplateId());
        snapshot.setInstanceId(instance.getId());
        snapshot.setTitle(instance.getTitleSnapshot());
        snapshot.setDescription(instance.getDescriptionSnapshot());
        snapshot.setStatus(instance.getStatus());
        snapshot.setPriority(instance.getPrioritySnapshot());
        snapshot.setCategory(instance.getCategorySnapshot());
        snapshot.setOccurrenceDate(instance.getOccurrenceDate());
        snapshot.setScheduledDate(instance.getScheduledDate());
        snapshot.setDueDateTime(instance.getDueDateTime());
        snapshot.setLinkedScheduleBlockId(instance.getLinkedScheduleBlockIdSnapshot());
        return snapshot;
    }

    public String displayTitle() {
        return title == null || title.isBlank()
                ? "Untitled task"
                : title;
    }
}