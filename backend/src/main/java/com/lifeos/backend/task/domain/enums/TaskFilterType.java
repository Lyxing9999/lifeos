package com.lifeos.backend.task.domain.enums;

public enum TaskFilterType {
    ALL,
    ACTIVE,
    COMPLETED,
    ARCHIVED;

    public static TaskFilterType from(String value, TaskFilterType fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }

        String normalized = value.trim().toUpperCase();
        if ("DONE".equals(normalized)) {
            return COMPLETED;
        }

        try {
            return TaskFilterType.valueOf(normalized);
        } catch (IllegalArgumentException ex) {
            return fallback;
        }
    }

    public boolean isArchived() {
        return this == ARCHIVED;
    }
}
