package com.lifeos.backend.schedule.infrastructure.mapper;

import com.lifeos.backend.schedule.api.response.ScheduleAvailabilityResponse;
import com.lifeos.backend.schedule.application.query.ScheduleAvailabilityQueryService.AvailabilityCheckResult;
import com.lifeos.backend.schedule.domain.valueobject.AvailabilityWindow;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class ScheduleAvailabilityMapper {

    private final ScheduleOccurrenceMapper occurrenceMapper;

    public ScheduleAvailabilityResponse toAvailabilityResponse(
            UUID userId,
            LocalDate date,
            LocalDateTime rangeStart,
            LocalDateTime rangeEnd,
            List<AvailabilityWindow> windows
    ) {
        List<AvailabilityWindow> safeWindows = windows == null
                ? List.of()
                : windows;

        return ScheduleAvailabilityResponse.builder()
                .userId(userId)
                .date(date)
                .rangeStart(rangeStart)
                .rangeEnd(rangeEnd)
                .available(!safeWindows.isEmpty())
                .windows(
                        safeWindows.stream()
                                .map(this::toWindowResponse)
                                .toList()
                )
                .conflicts(List.of())
                .totalWindows(safeWindows.size())
                .totalConflicts(0)
                .build();
    }

    public ScheduleAvailabilityResponse toCheckResponse(
            AvailabilityCheckResult result
    ) {
        if (result == null) {
            return null;
        }

        return ScheduleAvailabilityResponse.builder()
                .userId(result.userId())
                .rangeStart(result.startDateTime())
                .rangeEnd(result.endDateTime())
                .available(result.available())
                .windows(List.of())
                .conflicts(
                        result.conflicts() == null
                                ? List.of()
                                : result.conflicts()
                                .stream()
                                .map(occurrenceMapper::toResponse)
                                .toList()
                )
                .totalWindows(0)
                .totalConflicts(
                        result.conflicts() == null
                                ? 0
                                : result.conflicts().size()
                )
                .build();
    }

    private ScheduleAvailabilityResponse.AvailabilityWindowResponse toWindowResponse(
            AvailabilityWindow window
    ) {
        if (window == null) {
            return null;
        }

        return ScheduleAvailabilityResponse.AvailabilityWindowResponse.builder()
                .startDateTime(window.getStartDateTime())
                .endDateTime(window.getEndDateTime())
                .durationMinutes(window.getDurationMinutes())
                .build();
    }
}