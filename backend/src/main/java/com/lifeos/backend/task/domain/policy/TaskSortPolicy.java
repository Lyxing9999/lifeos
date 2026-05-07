package com.lifeos.backend.task.domain.policy;

import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;

@Component
public class TaskSortPolicy {

    public Comparator<Task> comparator() {
        return Comparator
                .comparingInt((Task task) -> taskModeRank(task.getTaskMode()))
                .thenComparingInt((Task task) -> priorityRank(task.getPriority()))
                .thenComparing((Task task) -> task.getDueDateTime() == null)
                .thenComparing(Task::getDueDateTime, Comparator.nullsLast(LocalDateTime::compareTo))
                .thenComparing((Task task) -> task.getDueDate() == null)
                .thenComparing(Task::getDueDate, Comparator.nullsLast(LocalDate::compareTo))
                .thenComparingInt((Task task) -> secondaryModeRank(task.getTaskMode()))
                .thenComparing(Task::getTitle, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private int taskModeRank(TaskMode mode) {
        if (mode == TaskMode.URGENT) {
            return 0;
        }

        return 1;
    }

    private int priorityRank(TaskPriority priority) {
        if (priority == null) {
            return 4;
        }

        return switch (priority) {
            case CRITICAL -> 0;
            case HIGH -> 1;
            case MEDIUM -> 2;
            case LOW -> 3;
        };
    }

    private int secondaryModeRank(TaskMode mode) {
        if (mode == null) {
            return 3;
        }

        return switch (mode) {
            case PROGRESS -> 0;
            case DAILY -> 1;
            case STANDARD -> 2;
            case URGENT -> 3;
        };
    }
}