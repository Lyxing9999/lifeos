package com.lifeos.backend.task.domain;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Entity
@Table(
        name = "tasks",
        indexes = {
                @Index(name = "idx_tasks_user_status", columnList = "userId,status"),
                @Index(name = "idx_tasks_user_mode", columnList = "userId,taskMode"),
                @Index(name = "idx_tasks_user_due_date", columnList = "userId,dueDate"),
                @Index(name = "idx_tasks_user_completed_at", columnList = "userId,completedAt"),
                @Index(name = "idx_tasks_user_achieved_date", columnList = "userId,achievedDate"),
                @Index(name = "idx_tasks_user_paused", columnList = "userId,paused")
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

    /**
     * Planned day / deadline.
     *
     * Do not change this when completing early or late.
     */
    private LocalDate dueDate;

    /**
     * Planned exact date-time / deadline date-time.
     *
     * Do not change this when completing early or late.
     */
    private LocalDateTime dueDateTime;

    private Integer progressPercent;

    private Instant startedAt;

    /**
     * Exact instant when this normal task was completed.
     *
     * For recurring tasks, per-day completion is stored in TaskCompletion.
     */
    private Instant completedAt;

    /**
     * Product day this normal task completion counts for.
     *
     * Examples:
     * - Inbox/no-date task completed today -> achievedDate = today.
     * - Due May 10 task completed May 8 -> dueDate = May 10, achievedDate = May 8.
     * - Due May 10 task completed May 15 -> dueDate = May 10, achievedDate = May 15.
     *
     * For recurring tasks, TaskCompletion.completionDate is the equivalent.
     */
    private LocalDate achievedDate;

    /**
     * View-cleanup timestamp.
     *
     * This does NOT mean deleted.
     * This does NOT mean archived.
     * This does NOT mean not achieved.
     *
     * It only means:
     * completed task is hidden from Done view,
     * but still kept for History / Timeline / analytics.
     */
    private Instant doneClearedAt;

    @Column(nullable = false)
    private Boolean archived = false;

    private Instant archivedAt;

    /**
     * Paused means:
     * user still cares about this task/habit/progress item,
     * but it should not appear in Today/Active until resumed.
     *
     * This is different from archive.
     */
    @Column(nullable = false)
    private Boolean paused = false;

    private Instant pausedAt;

    /**
     * Optional date when pause should end.
     *
     * For now, this is metadata. Query/service can decide later
     * whether to auto-resume or show "resume soon".
     */
    private LocalDate pauseUntil;

    @Embedded
    private TaskRecurrenceRule recurrenceRule = TaskRecurrenceRule.none();

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

    public boolean isArchived() {
        return Boolean.TRUE.equals(archived);
    }

    public boolean isPaused() {
        return Boolean.TRUE.equals(paused);
    }

    public boolean isActive() {
        return status != TaskStatus.COMPLETED
                && status != TaskStatus.CANCELLED
                && !isArchived()
                && !isPaused();
    }

    public boolean isRecurring() {
        return recurrenceRule != null
                && recurrenceRule.getType() != null
                && recurrenceRule.getType() != TaskRecurrenceType.NONE;
    }

    public boolean isDoneCleared() {
        return doneClearedAt != null;
    }

    public void start() {
        this.status = TaskStatus.IN_PROGRESS;

        if (this.startedAt == null) {
            this.startedAt = Instant.now();
        }
    }

    /**
     * Backward-compatible completion.
     *
     * Prefer completeForDate(...) from TaskCommandService so History/analysis
     * knows which product day the completion belongs to.
     */
    public void complete() {
        completeForDate(null);
    }

    public void completeForDate(LocalDate achievedDate) {
        this.status = TaskStatus.COMPLETED;
        this.completedAt = Instant.now();
        this.achievedDate = achievedDate;
        this.doneClearedAt = null;

        if (this.taskMode == TaskMode.PROGRESS) {
            this.progressPercent = 100;
        }
    }

    public void reopen() {
        this.status = TaskStatus.TODO;
        this.completedAt = null;
        this.achievedDate = null;
        this.doneClearedAt = null;

        if (this.progressPercent != null && this.progressPercent >= 100) {
            this.progressPercent = null;
        }
    }

    public void clearCompletion() {
        if (this.status != TaskStatus.COMPLETED) {
            this.completedAt = null;
            this.achievedDate = null;
            this.doneClearedAt = null;
        }
    }

    public void clearFromDone() {
        if (this.status == TaskStatus.COMPLETED) {
            this.doneClearedAt = Instant.now();
        }
    }

    public void restoreToDone() {
        this.doneClearedAt = null;
    }

    public void archive() {
        this.archived = true;
        this.archivedAt = Instant.now();
    }

    public void restore() {
        this.archived = false;
        this.archivedAt = null;
    }

    public void pause() {
        this.paused = true;
        this.pausedAt = Instant.now();
        this.pauseUntil = null;
    }

    public void pauseUntil(LocalDate pauseUntil) {
        this.paused = true;
        this.pausedAt = Instant.now();
        this.pauseUntil = pauseUntil;
    }

    public void resume() {
        this.paused = false;
        this.pausedAt = null;
        this.pauseUntil = null;
    }

    public void clearProgressIfNotProgressMode() {
        if (this.taskMode != TaskMode.PROGRESS) {
            this.progressPercent = null;
        }
    }

    public void addTag(String tagName) {
        String normalized = normalizeTagName(tagName);

        if (normalized == null) {
            return;
        }

        boolean alreadyExists = tags.stream()
                .anyMatch(tag -> tag.getName() != null
                        && tag.getName().equalsIgnoreCase(normalized));

        if (alreadyExists) {
            return;
        }

        TaskTag tag = new TaskTag();
        tag.setTask(this);
        tag.setName(normalized);
        tags.add(tag);
    }

    public void clearAndReplaceTags(Set<String> tagNames) {
        if (tagNames == null || tagNames.isEmpty()) {
            tags.clear();
            return;
        }

        Set<String> normalizedNames = tagNames.stream()
                .map(this::normalizeTagName)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toCollection(LinkedHashSet::new));

        tags.removeIf(existingTag -> {
            String existingName = normalizeTagName(existingTag.getName());
            return existingName == null || !normalizedNames.contains(existingName);
        });

        for (String name : normalizedNames) {
            addTag(name);
        }
    }

    private String normalizeTagName(String tagName) {
        if (tagName == null || tagName.isBlank()) {
            return null;
        }

        return tagName.trim().toLowerCase();
    }
}