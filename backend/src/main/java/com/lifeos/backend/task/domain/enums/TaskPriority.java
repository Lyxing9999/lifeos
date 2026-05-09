package com.lifeos.backend.task.domain.enums;

/**
 * Business priority of a task.
 *
 * This affects sorting, Today focus, notification urgency,
 * and later scoring/AI suggestions.
 */
public enum TaskPriority {

    /**
     * Must be handled soon.
     * Example: exam submission, payment deadline, urgent production bug.
     */
    CRITICAL(0),

    /**
     * Important but not emergency-level.
     * Example: project milestone, important study block.
     */
    HIGH(1),

    /**
     * Normal default priority.
     */
    MEDIUM(2),

    /**
     * Low-pressure task.
     * Example: optional cleanup, nice-to-have improvement.
     */
    LOW(3);

    private final int rank;

    TaskPriority(int rank) {
        this.rank = rank;
    }

    public int rank() {
        return rank;
    }

    public boolean isHighUrgency() {
        return this == CRITICAL || this == HIGH;
    }

    public boolean isLowerThan(TaskPriority other) {
        if (other == null) {
            return false;
        }

        return this.rank > other.rank;
    }

    public boolean isHigherThan(TaskPriority other) {
        if (other == null) {
            return true;
        }

        return this.rank < other.rank;
    }
}