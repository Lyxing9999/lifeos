package com.lifeos.backend.task.domain.enums;

/**
 * Where the task instance came from.
 */
public enum TaskSourceType {

    /**
     * User manually created this instance.
     */
    MANUAL,

    /**
     * Created from recurring template.
     */
    RECURRING_SPAWN,

    /**
     * Created by rolling over another instance.
     */
    ROLLOVER,

    /**
     * Created from schedule block.
     */
    SCHEDULE_LINKED,

    /**
     * Created by AI/suggestion system in the future.
     */
    AI_SUGGESTED
}