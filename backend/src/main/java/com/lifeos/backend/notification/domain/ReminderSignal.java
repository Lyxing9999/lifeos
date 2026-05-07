package com.lifeos.backend.notification.domain;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class ReminderSignal {
    private UUID userId;
    private LocalDate date;
    private Long activeTaskCount;
    private Long overdueTaskCount;
    private Integer overallScore;
    private boolean summaryReady;
}