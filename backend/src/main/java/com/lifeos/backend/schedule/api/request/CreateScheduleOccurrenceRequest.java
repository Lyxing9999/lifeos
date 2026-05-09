package com.lifeos.backend.schedule.api.request;

import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
public class CreateScheduleOccurrenceRequest {

    private UUID userId;

    private String title;
    private String description;
    private ScheduleBlockType type;

    private LocalDateTime startDateTime;
    private LocalDateTime endDateTime;

    private UUID linkedTaskInstanceId;
    private UUID linkedTaskTemplateId;
}