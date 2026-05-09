package com.lifeos.backend.task.domain.enums;

/**
 * Exception for one occurrence of a recurring template.
 *
 * Example:
 * - Skip only today
 * - Reschedule only today
 */
public enum TaskOccurrenceExceptionType {

    /**
     * Do not spawn this occurrence.
     * If already spawned, mark instance as SKIPPED.
     */
    SKIPPED,

    /**
     * This occurrence moved to a different date/time.
     */
    RESCHEDULED
}