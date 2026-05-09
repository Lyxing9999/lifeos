package com.lifeos.backend.timeline.api.request;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
public class RebuildTimelineRequest {

    private UUID userId;

    private LocalDate startDate;
    private LocalDate endDate;

    /**
     * If true, rebuild Task events.
     */
    private Boolean includeTasks = true;

    /**
     * If true, rebuild Schedule events.
     */
    private Boolean includeSchedule = true;

    /**
     * Later:
     * finance/stay/location backfill.
     */
    private Boolean includeFinance = false;
    private Boolean includeStay = false;
    private Boolean includeLocation = false;
}