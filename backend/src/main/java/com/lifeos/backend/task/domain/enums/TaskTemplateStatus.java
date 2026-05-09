package com.lifeos.backend.task.domain.enums;

/**
 * Status of the task blueprint.
 *
 * Template = intent / rule / recurring definition.
 * It should not become COMPLETED.
 * Completion belongs to TaskInstance.
 */
public enum TaskTemplateStatus {
    /**
     * Template can create future instances.
     */
    ACTIVE,

    /**
     * Template is temporarily stopped.
     * No new instances should spawn while paused.
     */
    PAUSED,

    /**
     * Template is hidden from active use.
     * Existing historical instances remain.
     */
    ARCHIVED
}