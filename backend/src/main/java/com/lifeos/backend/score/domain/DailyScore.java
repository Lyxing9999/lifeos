package com.lifeos.backend.score.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "daily_scores")
public class DailyScore extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private LocalDate scoreDate;

    @Column(nullable = false)
    private Integer completionScore;

    @Column(nullable = false)
    private Integer structureScore;

    @Column(nullable = false)
    private Integer overallScore;

    @Column(nullable = false)
    private Integer completedTasks;

    @Column(nullable = false)
    private Integer totalTasks;

    @Column(nullable = false)
    private Integer totalPlannedBlocks;

    @Column(nullable = false)
    private Integer totalStaySessions;

    @Column(columnDefinition = "TEXT")
    private String scoreExplanation;
}