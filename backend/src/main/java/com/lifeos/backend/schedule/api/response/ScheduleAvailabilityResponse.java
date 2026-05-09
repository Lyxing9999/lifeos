package com.lifeos.backend.schedule.api.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
public class ScheduleAvailabilityResponse {

    private UUID userId;

    private LocalDate date;

    private LocalDateTime rangeStart;
    private LocalDateTime rangeEnd;

    private Boolean available;

    private List<AvailabilityWindowResponse> windows;

    /**
     * Used by checkAvailability().
     */
    private List<ScheduleOccurrenceResponse> conflicts;

    private Integer totalWindows;
    private Integer totalConflicts;

    @Getter
    @Builder
    public static class AvailabilityWindowResponse {
        private LocalDateTime startDateTime;
        private LocalDateTime endDateTime;
        private Long durationMinutes;
    }
}