package com.lifeos.backend.task.domain.enums;

/**
 * Scope of recurrence edit.
 */
public enum TaskOccurrenceExceptionScope {

    /**
     * Only one date/occurrence.
     */
    THIS_OCCURRENCE,

    /**
     * This occurrence and all future occurrences.
     * Implement later.
     */
    THIS_AND_FUTURE,

    /**
     * Entire recurring template.
     * Implement later.
     */
    ENTIRE_SERIES
}