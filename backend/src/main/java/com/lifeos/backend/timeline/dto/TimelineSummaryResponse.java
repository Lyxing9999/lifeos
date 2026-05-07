package com.lifeos.backend.timeline.dto;

import lombok.Builder;
import lombok.Getter;

/**
 * Aggregated summary statistics for a timeline day.
 * <ul>
 *   <li><b>totalLocationLogs</b>: Number of location logs for the day.</li>
 *   <li><b>totalStaySessions</b>: Number of stay sessions for the day.</li>
 *   <li><b>totalTasks</b>: Number of tasks for the day.</li>
 *   <li><b>completedTasks</b>: Number of completed tasks for the day.</li>
 *   <li><b>totalPlannedBlocks</b>: Number of planned schedule blocks for the day.</li>
 *   <li><b>topPlaceName</b>: Name of the place with the longest stay ("No dominant place" if none).</li>
 *   <li><b>topPlaceDurationMinutes</b>: Duration in minutes at the top place (0 if none).</li>
 * </ul>
 */
@Getter
@Builder
public class TimelineSummaryResponse {
    private long totalLocationLogs;
    private long totalStaySessions;
    private long totalTasks;
    private long completedTasks;
    private long totalPlannedBlocks;

    /** Name of the top place, or "No dominant place" if none. */
    private String topPlaceName;
    /** Duration in minutes at the top place, or 0 if none. */
    private Long topPlaceDurationMinutes;
}