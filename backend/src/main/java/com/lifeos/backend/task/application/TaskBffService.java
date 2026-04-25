package com.lifeos.backend.task.application;

import com.lifeos.backend.task.api.response.TaskCountSummaryResponse;
import com.lifeos.backend.task.api.response.TaskOverviewBffResponse;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.api.response.TaskSectionResponse;
import com.lifeos.backend.task.domain.TaskFilterType;
import com.lifeos.backend.task.domain.TaskMode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TaskBffService {

    private final TaskService taskService;

    public TaskOverviewBffResponse getOverview(UUID userId, LocalDate date) {
        List<TaskResponse> today = taskService.getRelevantTasksByUserAndDay(userId, date, TaskFilterType.ALL);
        List<TaskResponse> last3 = collectDays(userId, date.minusDays(2), date);
        List<TaskResponse> last7 = collectDays(userId, date.minusDays(6), date);
        List<TaskResponse> last30 = collectDays(userId, date.minusDays(29), date);

        TaskResponse currentUrgentTask = firstByMode(today, TaskMode.URGENT);
        TaskResponse currentDailyTask = firstByMode(today, TaskMode.DAILY);
        TaskResponse currentProgressTask = firstByMode(today, TaskMode.PROGRESS);

        TaskResponse currentTask = currentUrgentTask != null
                ? currentUrgentTask
                : currentDailyTask != null
                ? currentDailyTask
                : currentProgressTask != null
                ? currentProgressTask
                : today.stream().findFirst().orElse(null);

        return TaskOverviewBffResponse.builder()
                .date(date)
                .currentTask(currentTask)
                .currentUrgentTask(currentUrgentTask)
                .currentDailyTask(currentDailyTask)
                .currentProgressTask(currentProgressTask)
                .todaySections(toSections(today))
                .last3DaySections(toSections(last3))
                .last7DaySections(toSections(last7))
                .last30DaySections(toSections(last30))
                .todayCounts(toCounts(today))
                .last3DayCounts(toCounts(last3))
                .last7DayCounts(toCounts(last7))
                .last30DayCounts(toCounts(last30))
                .recentCompletedTasks(last7.stream().filter(t -> t.getCompletedAt() != null).limit(10).toList())
                .build();
    }

    private List<TaskResponse> collectDays(UUID userId, LocalDate start, LocalDate end) {
        java.util.ArrayList<TaskResponse> all = new java.util.ArrayList<>();
        for (LocalDate d = start; !d.isAfter(end); d = d.plusDays(1)) {
            all.addAll(taskService.getRelevantTasksByUserAndDay(userId, d, TaskFilterType.ALL));
        }
        return all;
    }

    private TaskResponse firstByMode(List<TaskResponse> tasks, TaskMode mode) {
        return tasks.stream().filter(t -> t.getTaskMode() == mode).findFirst().orElse(null);
    }

    private TaskSectionResponse toSections(List<TaskResponse> tasks) {
        return TaskSectionResponse.builder()
                .urgentTasks(tasks.stream().filter(t -> t.getTaskMode() == TaskMode.URGENT).toList())
                .dailyTasks(tasks.stream().filter(t -> t.getTaskMode() == TaskMode.DAILY).toList())
                .progressTasks(tasks.stream().filter(t -> t.getTaskMode() == TaskMode.PROGRESS).toList())
                .standardTasks(tasks.stream().filter(t -> t.getTaskMode() == TaskMode.STANDARD).toList())
                .build();
    }

    private TaskCountSummaryResponse toCounts(List<TaskResponse> tasks) {
        return TaskCountSummaryResponse.builder()
                .total(tasks.size())
                .active((int) tasks.stream().filter(t -> t.getStatus() != com.lifeos.backend.task.domain.TaskStatus.COMPLETED
                        && t.getStatus() != com.lifeos.backend.task.domain.TaskStatus.CANCELLED).count())
                .completed((int) tasks.stream().filter(t -> t.getStatus() == com.lifeos.backend.task.domain.TaskStatus.COMPLETED).count())
                .urgent((int) tasks.stream().filter(t -> t.getTaskMode() == TaskMode.URGENT).count())
                .daily((int) tasks.stream().filter(t -> t.getTaskMode() == TaskMode.DAILY).count())
                .progress((int) tasks.stream().filter(t -> t.getTaskMode() == TaskMode.PROGRESS).count())
                .build();
    }
}