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
}