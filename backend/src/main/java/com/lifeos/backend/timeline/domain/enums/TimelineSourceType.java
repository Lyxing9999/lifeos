package com.lifeos.backend.timeline.domain.enums;

/**
 * Which domain/module produced this timeline entry.
 */
public enum TimelineSourceType {

    TASK,
    SCHEDULE,
    STAY,
    LOCATION,
    FINANCIAL,
    SUMMARY,
    SYSTEM;

    public boolean isExternalFact() {
        return this == LOCATION || this == FINANCIAL;
    }

    public boolean isCoreLifeOsDomain() {
        return this == TASK
                || this == SCHEDULE
                || this == STAY
                || this == SUMMARY;
    }
}