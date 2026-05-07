package com.lifeos.backend.task.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(
        name = "task_tags",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_task_tags_task_name", columnNames = {"task_id", "name"})
        }
)
@Getter
@Setter
public class TaskTag extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "task_id", nullable = false)
    private Task task;

    @Column(nullable = false, length = 100)
    private String name;

    public TaskTag() {
    }

    public TaskTag(String name) {
        this.name = normalize(name);
    }

    public void setName(String name) {
        this.name = normalize(name);
    }

    private String normalize(String raw) {
        if (raw == null) {
            return null;
        }
        return raw.trim();
    }

    public boolean sameName(String other) {
        if (name == null || other == null) {
            return false;
        }
        return name.equalsIgnoreCase(other.trim());
    }
}