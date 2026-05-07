package com.lifeos.backend.today.dto;

import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
public class TodayCurrentScheduleResponse {
    private UUID scheduleBlockId;
    private String title;
    private ScheduleBlockType type;
    private LocalDateTime startDateTime;
    private LocalDateTime endDateTime;
    private boolean activeNow;
}