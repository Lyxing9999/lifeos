package com.lifeos.backend.schedule.api.response;

import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import lombok.Builder;
import lombok.Getter;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Builder
public class ScheduleSelectOptionResponse {
    private UUID value;
    private String label;
    private UUID scheduleBlockId;
    private String title;
    private ScheduleBlockType type;
    private LocalTime startTime;
    private LocalTime endTime;
    private Boolean active;
}