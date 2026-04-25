package com.lifeos.backend.schedule.application;

import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.domain.ScheduleBlock;
import org.springframework.stereotype.Component;

@Component
public class ScheduleBlockMapper {

    public ScheduleBlock toEntity(CreateScheduleBlockRequest request) {
        ScheduleBlock block = new ScheduleBlock();
        block.setUserId(request.getUserId());
        block.setTitle(request.getTitle());
        block.setType(request.getType());
        block.setDescription(request.getDescription());
        block.setStartTime(request.getStartTime());
        block.setEndTime(request.getEndTime());
        block.setRecurrenceType(request.getRecurrenceType());
        block.setRecurrenceDaysOfWeek(request.getRecurrenceDaysOfWeek());
        block.setRecurrenceStartDate(request.getRecurrenceStartDate());
        block.setRecurrenceEndDate(request.getRecurrenceEndDate());
        return block;
    }

    public ScheduleBlockResponse toResponse(ScheduleBlock block) {
        return ScheduleBlockResponse.builder()
                .id(block.getId())
                .userId(block.getUserId())
                .title(block.getTitle())
                .type(block.getType())
                .description(block.getDescription())
                .startTime(block.getStartTime())
                .endTime(block.getEndTime())
                .recurrenceType(block.getRecurrenceType())
                .recurrenceDaysOfWeek(block.getRecurrenceDaysOfWeek())
                .recurrenceStartDate(block.getRecurrenceStartDate())
                .recurrenceEndDate(block.getRecurrenceEndDate())
                .active(block.getActive())
                .build();
    }
}