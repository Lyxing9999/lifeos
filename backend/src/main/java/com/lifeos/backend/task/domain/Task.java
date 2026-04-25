package com.lifeos.backend.task.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(
        name = "tasks",
        indexes = {
                @Index(name = "idx_tasks_user_status", columnList = "userId,status"),
                @Index(name = "idx_tasks_user_mode", columnList = "userId,taskMode"),
                @Index(name = "idx_tasks_user_due_date", columnList = "userId,dueDate"),
                @Index(name = "idx_tasks_user_completed_at", columnList = "userId,completedAt")
        }
)
@Getter
@Setter
public class Task extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false, length = 300)
    private String title;

    @Column(length = 4000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskStatus status = TaskStatus.TODO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskMode taskMode = TaskMode.STANDARD;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskPriority priority = TaskPriority.MEDIUM;

    @Column(length = 100)
    private String category;

    private LocalDate dueDate;

    private LocalDateTime dueDateTime;

    private Integer progressPercent;

    private Instant startedAt;

    private Instant completedAt;

    @Column(nullable = false)
    private Boolean archived = false;

    private Instant archivedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskRecurrenceType recurrenceType = TaskRecurrenceType.NONE;

    private LocalDate recurrenceStartDate;

    private LocalDate recurrenceEndDate;

    @Column(length = 120)
    private String recurrenceDaysOfWeek;

    @Column(length = 60)
    private UUID linkedScheduleBlockId;

    @OneToMany(
            mappedBy = "task",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private Set<TaskTag> tags = new LinkedHashSet<>();

    public boolean isCompleted() {
        return status == TaskStatus.COMPLETED;
    }

    public boolean isActive() {
        return status != TaskStatus.COMPLETED
                && status != TaskStatus.CANCELLED
                && Boolean.FALSE.equals(archived);
    }

    public void addTag(String tagName) {
        if (tagName == null || tagName.isBlank()) return;
        TaskTag tag = new TaskTag();
        tag.setTask(this);
        tag.setName(tagName.trim());
        tags.add(tag);
    }

    public void clearAndReplaceTags(Set<String> tagNames) {
        tags.clear();
        if (tagNames == null) return;
        for (String name : tagNames) {
            addTag(name);
        }
    }
}