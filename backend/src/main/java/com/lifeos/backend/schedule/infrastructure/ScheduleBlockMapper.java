package com.lifeos.backend.schedule.infrastructure;

import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.api.response.ScheduleSelectOptionResponse;
import com.lifeos.backend.schedule.domain.ScheduleBlock;
import org.springframework.stereotype.Component;

@Component
public class ScheduleBlockMapper {

    public ScheduleBlock toEntity(CreateScheduleBlockRequest request) {
        ScheduleBlock block = new ScheduleBlock();
        block.setTitle(request.getTitle());
        block.setDescription(request.getDescription());
        block.setType(request.getType());
        block.setStartTime(request.getStartTime());
        block.setEndTime(request.getEndTime());
        block.setRecurrenceType(request.getRecurrenceType());
        block.setRecurrenceDaysOfWeek(request.getRecurrenceDaysOfWeek());
        block.setRecurrenceStartDate(request.getRecurrenceStartDate());
        block.setRecurrenceEndDate(request.getRecurrenceEndDate());
        block.setActive(true);
        return block;
    }

    public ScheduleBlockResponse toResponse(ScheduleBlock block) {
        return ScheduleBlockResponse.builder()
                .id(block.getId())
                .userId(block.getUserId())
                .title(block.getTitle())
                .description(block.getDescription())
                .type(block.getType())
                .startTime(block.getStartTime())
                .endTime(block.getEndTime())
                .recurrenceType(block.getRecurrenceType())
                .recurrenceDaysOfWeek(block.getRecurrenceDaysOfWeek())
                .recurrenceStartDate(block.getRecurrenceStartDate())
                .recurrenceEndDate(block.getRecurrenceEndDate())
                .active(block.getActive())
                .build();
    }

    public ScheduleSelectOptionResponse toSelectOption(ScheduleBlock block) {
        String label = String.format("%s · %s–%s", block.getTitle(), block.getStartTime(), block.getEndTime());
        return ScheduleSelectOptionResponse.builder()
                .value(block.getId())
                .scheduleBlockId(block.getId())
                .label(label)
                .title(block.getTitle())
                .type(block.getType())
                .startTime(block.getStartTime())
                .endTime(block.getEndTime())
                .active(block.getActive())
                .build();
    }
}