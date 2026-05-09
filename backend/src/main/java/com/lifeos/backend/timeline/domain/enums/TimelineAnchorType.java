package com.lifeos.backend.timeline.domain.enums;

public enum TimelineAnchorType {

    /**
     * One moment.
     *
     * Examples:
     * - task completed at 10:15
     * - financial transaction at 12:30
     */
    POINT,

    /**
     * Time range.
     *
     * Examples:
     * - schedule block 09:00-11:00
     * - stay session 18:00-08:00 next day
     */
    SPAN,

    /**
     * Whole-day marker.
     *
     * Examples:
     * - daily summary
     * - holiday
     * - all-day travel
     */
    ALL_DAY
}