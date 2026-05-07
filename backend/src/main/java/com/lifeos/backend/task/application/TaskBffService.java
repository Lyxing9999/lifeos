package com.lifeos.backend.task.application;

import com.lifeos.backend.task.api.response.TaskCountSummaryResponse;
import com.lifeos.backend.task.api.response.TaskOverviewBffResponse;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.api.response.TaskSectionResponse;
import com.lifeos.backend.task.api.response.TaskSurfaceBffResponse;
import com.lifeos.backend.task.domain.enums.TaskFilterType;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TaskBffService {

        private final TaskQueryService taskQueryService;

        public TaskSurfaceBffResponse getSurfaces(
                UUID userId,
                LocalDate date,
                TaskFilterType filter) {
                TaskFilterType safeFilter = filter == null ? TaskFilterType.ACTIVE : filter;

                // FIX: Route through the domain logic instead of a raw SQL due-date query
                List<TaskResponse> dueTasks = taskQueryService.getRelevantTasksByUserAndDay(userId, date, safeFilter);

                List<TaskResponse> doneTasks = taskQueryService.getDoneTasks(userId, date);
                List<TaskResponse> inboxTasks = taskQueryService.getInboxTasks(userId);
                List<TaskResponse> allTasks = taskQueryService.getAllActiveTasks(userId);
                List<TaskResponse> pausedTasks = taskQueryService.getPausedTasks(userId);
                List<TaskResponse> historyTasks = taskQueryService.getHistoryTasks(userId, date);
                List<TaskResponse> archivedTasks = taskQueryService.getArchivedTasks(userId, TaskFilterType.ALL);

                List<TaskResponse> scheduleLinkedTasks = dueTasks.stream()
                        .filter(this::isScheduleLinked)
                        .toList();

                List<TaskResponse> todayTasks = dueTasks.stream()
                        .filter(task -> !isScheduleLinked(task))
                        .toList();

                return TaskSurfaceBffResponse.builder()
                        .date(date)
                        .filter(safeFilter)
                        .dueTasks(dueTasks)
                        .inboxTasks(inboxTasks)
                        .doneTasks(doneTasks)
                        .allTasks(allTasks)
                        .pausedTasks(pausedTasks)
                        .historyTasks(historyTasks)
                        .archivedTasks(archivedTasks)
                        .todayTasks(todayTasks)
                        .scheduleLinkedTasks(scheduleLinkedTasks)
                        .anytimeTasks(inboxTasks)
                        .achievedTasks(historyTasks)
                        .dueCounts(toCounts(dueTasks))
                        .inboxCounts(toCounts(inboxTasks))
                        .doneCounts(toCounts(doneTasks))
                        .allCounts(toCounts(allTasks))
                        .pausedCounts(toCounts(pausedTasks))
                        .historyCounts(toCounts(historyTasks))
                        .archivedCounts(toCounts(archivedTasks))
                        .todayCounts(toCounts(todayTasks))
                        .scheduleLinkedCounts(toCounts(scheduleLinkedTasks))
                        .anytimeCounts(toCounts(inboxTasks))
                        .achievedCounts(toCounts(historyTasks))
                        .build();
        }

        public TaskOverviewBffResponse getOverview(UUID userId, LocalDate date) {
                // FIX: Route through the domain logic using TaskFilterType.ACTIVE
                List<TaskResponse> today = taskQueryService.getRelevantTasksByUserAndDay(userId, date, TaskFilterType.ACTIVE);

                List<TaskResponse> inbox = taskQueryService.getInboxTasks(userId);
                List<TaskResponse> history = taskQueryService.getHistoryTasks(userId, date);

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
                        .anytimeCounts(toCounts(inbox))
                        .anytimePreviewTasks(inbox.stream().limit(5).toList())
                        .recentCompletedTasks(history.stream().limit(10).toList())
                        .build();
        }

        private List<TaskResponse> collectDays(UUID userId, LocalDate start, LocalDate end) {
                ArrayList<TaskResponse> all = new ArrayList<>();
                for (LocalDate day = start; !day.isAfter(end); day = day.plusDays(1)) {
                        all.addAll(taskQueryService.getRelevantTasksByUserAndDay(userId, day, TaskFilterType.ALL));
                }
                return all;
        }

        private TaskResponse firstByMode(List<TaskResponse> tasks, TaskMode mode) {
                return tasks.stream()
                        .filter(task -> task.getTaskMode() == mode)
                        .findFirst()
                        .orElse(null);
        }

        private boolean isScheduleLinked(TaskResponse task) {
                return task.getLinkedScheduleBlockId() != null;
        }

        private TaskSectionResponse toSections(List<TaskResponse> tasks) {
                return TaskSectionResponse.builder()
                        .urgentTasks(tasks.stream().filter(task -> task.getTaskMode() == TaskMode.URGENT).toList())
                        .dailyTasks(tasks.stream().filter(task -> task.getTaskMode() == TaskMode.DAILY).toList())
                        .progressTasks(tasks.stream().filter(task -> task.getTaskMode() == TaskMode.PROGRESS).toList())
                        .standardTasks(tasks.stream().filter(task -> task.getTaskMode() == TaskMode.STANDARD).toList())
                        .build();
        }

        private TaskCountSummaryResponse toCounts(List<TaskResponse> tasks) {
                return TaskCountSummaryResponse.builder()
                        .total(tasks.size())
                        .active((int) tasks.stream()
                                .filter(task -> task.getStatus() != TaskStatus.COMPLETED && task.getStatus() != TaskStatus.CANCELLED)
                                .count())
                        .completed((int) tasks.stream()
                                .filter(task -> task.getStatus() == TaskStatus.COMPLETED)
                                .count())
                        .urgent((int) tasks.stream()
                                .filter(task -> task.getTaskMode() == TaskMode.URGENT)
                                .count())
                        .daily((int) tasks.stream()
                                .filter(task -> task.getTaskMode() == TaskMode.DAILY)
                                .count())
                        .progress((int) tasks.stream()
                                .filter(task -> task.getTaskMode() == TaskMode.PROGRESS)
                                .count())
                        .build();
        }
}