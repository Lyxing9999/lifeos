package com.lifeos.backend.today.application;

import com.lifeos.backend.task.api.response.TaskInstanceResponse;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.infrastructure.mapper.TaskInstanceMapper;
import com.lifeos.backend.today.api.response.TodayTaskSectionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.List;

@Component
@RequiredArgsConstructor
public class TodayTaskSectionAssembler {

    private final TaskInstanceMapper taskInstanceMapper;

    public TodayTaskSectionResponse assemble(
            List<TaskInstance> scheduledToday,
            List<TaskInstance> overdue,
            List<TaskInstance> inbox,
            List<TaskInstance> completedToday
    ) {
        List<TaskInstance> safeScheduledToday = safeList(scheduledToday);
        List<TaskInstance> safeOverdue = safeList(overdue);
        List<TaskInstance> safeInbox = safeList(inbox);
        List<TaskInstance> safeCompletedToday = safeList(completedToday);

        List<TaskInstance> inProgress = safeScheduledToday.stream()
                .filter(task -> task.getStatus() == TaskInstanceStatus.IN_PROGRESS)
                .sorted(taskComparator())
                .toList();

        List<TaskInstance> dueToday = safeScheduledToday.stream()
                .filter(task -> task.getStatus() == TaskInstanceStatus.DUE_TODAY
                        || task.getStatus() == TaskInstanceStatus.SCHEDULED
                        || task.getStatus() == TaskInstanceStatus.IN_PROGRESS)
                .sorted(taskComparator())
                .toList();

        List<TaskInstance> topTasks = java.util.stream.Stream
                .concat(safeOverdue.stream(), dueToday.stream())
                .sorted(taskComparator())
                .limit(5)
                .toList();

        int totalOpen = safeOverdue.size()
                + dueToday.size()
                + safeInbox.size();

        return TodayTaskSectionResponse.builder()
                .overdueTasks(map(safeOverdue))
                .dueTodayTasks(map(dueToday))
                .inProgressTasks(map(inProgress))
                .inboxTasks(map(safeInbox))
                .completedTodayTasks(map(safeCompletedToday))
                .topTasks(map(topTasks))

                .overdueCount(safeOverdue.size())
                .dueTodayCount(dueToday.size())
                .inProgressCount(inProgress.size())
                .inboxCount(safeInbox.size())
                .completedTodayCount(safeCompletedToday.size())
                .totalOpenCount(totalOpen)
                .build();
    }

    private List<TaskInstanceResponse> map(List<TaskInstance> tasks) {
        return safeList(tasks).stream()
                .map(taskInstanceMapper::toResponse)
                .toList();
    }

    private Comparator<TaskInstance> taskComparator() {
        return Comparator
                .comparingInt(this::statusRank)
                .thenComparingInt(this::priorityRank)
                .thenComparing(TaskInstance::getDueDateTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TaskInstance::getScheduledDate, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TaskInstance::getTitleSnapshot, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private int statusRank(TaskInstance task) {
        if (task == null || task.getStatus() == null) {
            return 99;
        }

        return switch (task.getStatus()) {
            case OVERDUE -> 0;
            case IN_PROGRESS -> 1;
            case DUE_TODAY -> 2;
            case SCHEDULED -> 3;
            case INBOX -> 4;
            case COMPLETED -> 5;
            case MISSED -> 6;
            case SKIPPED -> 7;
            case ROLLED_OVER -> 8;
            case PAUSED -> 9;
            case ARCHIVED -> 10;
            case CANCELLED -> 11;
        };
    }

    private int priorityRank(TaskInstance task) {
        if (task == null || task.getPrioritySnapshot() == null) {
            return 99;
        }

        return switch (task.getPrioritySnapshot()) {
            case CRITICAL -> 0;
            case HIGH -> 1;
            case MEDIUM -> 2;
            case LOW -> 3;
        };
    }

    private <T> List<T> safeList(List<T> list) {
        return list == null ? List.of() : list;
    }
}