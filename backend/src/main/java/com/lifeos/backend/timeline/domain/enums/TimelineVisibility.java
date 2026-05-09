package com.lifeos.backend.timeline.domain.enums;

/**
 * Timeline visibility controls read behavior without deleting history.
 */
public enum TimelineVisibility {

    /**
     * Normal visible timeline entry.
     */
    VISIBLE,

    /**
     * Hidden from default timeline, but preserved for audit/debug.
     */
    HIDDEN,

    /**
     * Soft-deleted. Do not show in normal product views.
     */
    DELETED;

    public boolean isVisible() {
        return this == VISIBLE;
    }

    public boolean isHidden() {
        return this == HIDDEN;
    }

    public boolean isDeleted() {
        return this == DELETED;
    }
}