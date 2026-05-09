package com.lifeos.backend.today.application;

import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.task.api.response.TaskInstanceResponse;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.today.api.response.TodayCurrentFocusResponse;
import com.lifeos.backend.today.api.response.TodayScheduleSectionResponse;
import com.lifeos.backend.today.api.response.TodayTaskSectionResponse;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

@Component
public class TodayCurrentFocusResolver {

    public TodayCurrentFocusResponse resolve(
            TodayTaskSectionResponse tasks,
            TodayScheduleSectionResponse schedule
    ) {
        ScheduleOccurrenceResponse currentSchedule = schedule == null
                ? null
                : schedule.getCurrentSchedule();

        TaskInstanceResponse linkedTask = findTaskLinkedToCurrentSchedule(tasks, currentSchedule);

        if (currentSchedule != null && linkedTask != null) {
            return TodayCurrentFocusResponse.builder()
                    .focusType("TASK_IN_SCHEDULE")
                    .title(linkedTask.getTitle())
                    .subtitle(currentSchedule.getTitle())
                    .reason("Current schedule has a linked task")
                    .activeNow(true)
                    .urgent(isUrgent(linkedTask))
                    .blockedBySchedule(false)
                    .task(linkedTask)
                    .schedule(currentSchedule)
                    .build();
        }

        if (currentSchedule != null) {
            return TodayCurrentFocusResponse.builder()
                    .focusType("SCHEDULE")
                    .title(currentSchedule.getTitle())
                    .subtitle("Current time block")
                    .reason("A schedule block is active now")
                    .activeNow(true)
                    .urgent(false)
                    .blockedBySchedule(false)
                    .schedule(currentSchedule)
                    .build();
        }

        TaskInstanceResponse topTask = chooseTopTask(tasks);

        if (topTask != null) {
            return TodayCurrentFocusResponse.builder()
                    .focusType("TASK")
                    .title(topTask.getTitle())
                    .subtitle(topTask.getStatus() == null ? "Task" : topTask.getStatus().name())
                    .reason(resolveTaskReason(topTask))
                    .activeNow(false)
                    .urgent(isUrgent(topTask))
                    .blockedBySchedule(false)
                    .task(topTask)
                    .build();
        }

        ScheduleOccurrenceResponse nextSchedule = schedule == null
                ? null
                : schedule.getNextSchedule();

        if (nextSchedule != null) {
            return TodayCurrentFocusResponse.builder()
                    .focusType("FREE_TIME")
                    .title("Free time before " + nextSchedule.getTitle())
                    .subtitle("Next schedule is coming")
                    .reason("No active schedule or urgent task")
                    .activeNow(false)
                    .urgent(false)
                    .blockedBySchedule(false)
                    .schedule(nextSchedule)
                    .build();
        }

        return TodayCurrentFocusResponse.builder()
                .focusType("NONE")
                .title("Clear")
                .subtitle("No immediate focus")
                .reason("No active schedule and no open task")
                .activeNow(false)
                .urgent(false)
                .blockedBySchedule(false)
                .build();
    }

    private TaskInstanceResponse findTaskLinkedToCurrentSchedule(
            TodayTaskSectionResponse tasks,
            ScheduleOccurrenceResponse currentSchedule
    ) {
        if (tasks == null || currentSchedule == null) {
            return null;
        }

        UUID linkedTaskInstanceId = currentSchedule.getLinkedTaskInstanceId();

        if (linkedTaskInstanceId == null) {
            return null;
        }

        return allOpenTasks(tasks)
                .stream()
                .filter(task -> linkedTaskInstanceId.equals(task.getId()))
                .findFirst()
                .orElse(null);
    }

    private TaskInstanceResponse chooseTopTask(TodayTaskSectionResponse tasks) {
        if (tasks == null) {
            return null;
        }

        return allOpenTasks(tasks).stream()
                .sorted(taskComparator())
                .findFirst()
                .orElse(null);
    }

    private List<TaskInstanceResponse> allOpenTasks(TodayTaskSectionResponse tasks) {
        return java.util.stream.Stream.of(
                        safeList(tasks.getOverdueTasks()),
                        safeList(tasks.getInProgressTasks()),
                        safeList(tasks.getDueTodayTasks()),
                        safeList(tasks.getInboxTasks())
                )
                .flatMap(List::stream)
                .filter(Objects::nonNull)
                .distinct()
                .toList();
    }

    private Comparator<TaskInstanceResponse> taskComparator() {
        return Comparator
                .comparingInt(this::statusRank)
                .thenComparingInt(this::priorityRank)
                .thenComparing(TaskInstanceResponse::getDueDateTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TaskInstanceResponse::getTitle, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private int statusRank(TaskInstanceResponse task) {
        if (task == null || task.getStatus() == null) {
            return 99;
        }

        return switch (task.getStatus()) {
            case OVERDUE -> 0;
            case IN_PROGRESS -> 1;
            case DUE_TODAY -> 2;
            case SCHEDULED -> 3;
            case INBOX -> 4;
            default -> 50;
        };
    }

    private int priorityRank(TaskInstanceResponse task) {
        TaskPriority priority = task == null ? null : task.getPriority();

        if (priority == null) {
            return 99;
        }

        return switch (priority) {
            case CRITICAL -> 0;
            case HIGH -> 1;
            case MEDIUM -> 2;
            case LOW -> 3;
        };
    }

    private boolean isUrgent(TaskInstanceResponse task) {
        if (task == null) {
            return false;
        }

        return task.getStatus() == TaskInstanceStatus.OVERDUE
                || task.getPriority() == TaskPriority.CRITICAL
                || task.getPriority() == TaskPriority.HIGH;
    }

    private String resolveTaskReason(TaskInstanceResponse task) {
        if (task.getStatus() == TaskInstanceStatus.OVERDUE) {
            return "Task is overdue";
        }

        if (task.getStatus() == TaskInstanceStatus.IN_PROGRESS) {
            return "Task is already in progress";
        }

        if (task.getPriority() == TaskPriority.CRITICAL) {
            return "Critical priority task";
        }

        if (task.getPriority() == TaskPriority.HIGH) {
            return "High priority task";
        }

        return "Best available task right now";
    }

    private <T> List<T> safeList(List<T> list) {
        return list == null ? List.of() : list;
    }
}