package com.lifeos.backend.schedule.application;

import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleBlockRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ScheduleOccurrenceService {

    private final ScheduleBlockRepository repository;
    private final ScheduleRecurrenceResolver recurrenceResolver;

    public List<ScheduleOccurrenceResponse> getOccurrencesByUserIdAndDay(UUID userId, LocalDate date) {
        List<ScheduleBlock> blocks = repository.findByUserIdAndActiveTrue(userId);

        return blocks.stream()
                .filter(block -> recurrenceResolver.occursOn(block, date))
                .map(block -> ScheduleOccurrenceResponse.builder()
                        .scheduleBlockId(block.getId())
                        .userId(block.getUserId())
                        .title(block.getTitle())
                        .type(block.getType())
                        .occurrenceDate(date)
                        .startDateTime(date.atTime(block.getStartTime()))
                        .endDateTime(date.atTime(block.getEndTime()))
                        .build())
                .sorted(Comparator.comparing(ScheduleOccurrenceResponse::getStartDateTime))
                .toList();
    }
}