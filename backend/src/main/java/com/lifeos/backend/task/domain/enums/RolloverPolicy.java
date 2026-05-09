package com.lifeos.backend.task.domain.enums;

/**
 * Defines what happens when an instance is unfinished
 * after its intended date/time window.
 */
public enum RolloverPolicy {

    /**
     * Never rollover automatically.
     * Usually become MISSED or OVERDUE depending on MissedPolicy.
     */
    DO_NOT_ROLLOVER,

    /**
     * Move unfinished work to the next local day.
     */
    ROLLOVER_TO_NEXT_DAY,

    /**
     * Move to the next valid recurrence day.
     * Example: Mon/Wed/Fri task missed on Monday -> rollover to Wednesday.
     */
    ROLLOVER_TO_NEXT_AVAILABLE_DAY,

    /**
     * Do not move it. Keep it in OVERDUE state.
     */
    KEEP_OVERDUE;

    public boolean allowsRollover() {
        return this == ROLLOVER_TO_NEXT_DAY
                || this == ROLLOVER_TO_NEXT_AVAILABLE_DAY;
    }
}