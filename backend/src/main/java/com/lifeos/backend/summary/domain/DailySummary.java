package com.lifeos.backend.summary.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "daily_summaries")
@Getter
@Setter
public class DailySummary extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private LocalDate summaryDate;

    @Column(nullable = false, length = 3000)
    private String summaryText;

    private String topPlaceName;
    private Long totalTasks;
    private Long completedTasks;
    private Long totalPlannedBlocks;
    private Long totalStaySessions;

    @Column(length = 1000)
    private String scoreExplanationText;

    @Column(length = 1000)
    private String optionalInsight;
}