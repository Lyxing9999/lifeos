package com.lifeos.backend.task.api;

import com.lifeos.backend.task.api.request.CompleteTaskRequest;
import com.lifeos.backend.task.api.request.CreateTaskInstanceRequest;
import com.lifeos.backend.task.api.request.LifecycleReasonRequest;
import com.lifeos.backend.task.api.request.ReopenTaskRequest;
import com.lifeos.backend.task.api.request.RescheduleTaskRequest;
import com.lifeos.backend.task.api.request.RolloverTaskRequest;
import com.lifeos.backend.task.api.request.SkipOccurrenceRequest;
import com.lifeos.backend.task.api.response.TaskInstanceResponse;
import com.lifeos.backend.task.api.response.TaskLifecycleResultResponse;
import com.lifeos.backend.task.application.command.TaskCompletionService.DoneCleanupResult;
import com.lifeos.backend.task.application.command.TaskInstanceCommandService;
import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator.TaskLifecycleResult;
import com.lifeos.backend.task.application.command.TaskRescheduleService;
import com.lifeos.backend.task.application.command.TaskSkipOccurrenceService.SkipOccurrenceResult;
import com.lifeos.backend.task.application.query.TaskInstanceQueryService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.infrastructure.mapper.TaskInstanceMapper;
import com.lifeos.backend.task.infrastructure.mapper.TaskLifecycleResultMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/task-instances")
@RequiredArgsConstructor
public class TaskInstanceController {

    private final TaskInstanceCommandService commandService;
    private final TaskInstanceQueryService queryService;
    private final TaskRescheduleService taskRescheduleService;

    private final TaskInstanceMapper instanceMapper;
    private final TaskLifecycleResultMapper lifecycleResultMapper;

    @PostMapping("/inbox")
    public TaskInstanceResponse createInbox(
            @RequestBody CreateTaskInstanceRequest request
    ) {
        TaskInstance created = commandService.createInbox(
                new TaskInstanceCommandService.CreateInboxTaskCommand(
                        request.getUserId(),
                        request.getTitle(),
                        request.getDescription(),
                        request.getPriority(),
                        request.getCategory()
                )
        );

        return instanceMapper.toResponse(created);
    }

    @PostMapping("/scheduled")
    public TaskInstanceResponse createScheduled(
            @RequestBody CreateTaskInstanceRequest request
    ) {
        TaskInstance created = commandService.createScheduled(
                new TaskInstanceCommandService.CreateScheduledTaskCommand(
                        request.getUserId(),
                        request.getTitle(),
                        request.getDescription(),
                        request.getPriority(),
                        request.getCategory(),
                        request.getScheduledDate(),
                        request.getDueDateTime()
                )
        );

        return instanceMapper.toResponse(created);
    }

    @GetMapping("/{taskInstanceId}")
    public TaskInstanceResponse getById(
            @PathVariable UUID taskInstanceId,
            @RequestParam UUID userId
    ) {
        return instanceMapper.toResponse(
                queryService.getByIdForUser(userId, taskInstanceId)
        );
    }

    @GetMapping("/date")
    public List<TaskInstanceResponse> getByDate(
            @RequestParam UUID userId,
            @RequestParam LocalDate date
    ) {
        return queryService.getByScheduledDate(userId, date)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/range")
    public List<TaskInstanceResponse> getByDateRange(
            @RequestParam UUID userId,
            @RequestParam LocalDate startDate,
            @RequestParam LocalDate endDate
    ) {
        return queryService.getByScheduledDateRange(userId, startDate, endDate)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/inbox")
    public List<TaskInstanceResponse> getInbox(
            @RequestParam UUID userId
    ) {
        return queryService.getInbox(userId)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/overdue")
    public List<TaskInstanceResponse> getOverdue(
            @RequestParam UUID userId
    ) {
        return queryService.getOverdue(userId)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/paused")
    public List<TaskInstanceResponse> getPaused(
            @RequestParam UUID userId
    ) {
        return queryService.getPaused(userId)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/archived")
    public List<TaskInstanceResponse> getArchived(
            @RequestParam UUID userId
    ) {
        return queryService.getArchived(userId)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/missed")
    public List<TaskInstanceResponse> getMissed(
            @RequestParam UUID userId
    ) {
        return queryService.getMissed(userId)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/skipped")
    public List<TaskInstanceResponse> getSkipped(
            @RequestParam UUID userId
    ) {
        return queryService.getSkipped(userId)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/done")
    public List<TaskInstanceResponse> getDoneForDay(
            @RequestParam UUID userId,
            @RequestParam LocalDate date
    ) {
        return queryService.getCompletedForDay(userId, date)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @GetMapping("/history")
    public List<TaskInstanceResponse> getHistoryForDay(
            @RequestParam UUID userId,
            @RequestParam LocalDate date
    ) {
        return queryService.getCompletionHistoryForDay(userId, date)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    // FIXED: Now uses the native TaskInstanceQueryService and native TaskInstanceResponse
    @GetMapping("/day-truth")
    public List<TaskInstanceResponse> getDayTruth(
            @RequestParam UUID userId,
            @RequestParam LocalDate date
    ) {
        return queryService.getDayTruth(userId, date)
                .stream()
                .map(instanceMapper::toResponse)
                .toList();
    }

    @PostMapping("/{taskInstanceId}/start")
    public TaskLifecycleResultResponse start(
            @PathVariable UUID taskInstanceId,
            @RequestBody LifecycleReasonRequest request
    ) {
        TaskLifecycleResult result = commandService.start(
                request.getUserId(),
                taskInstanceId
        );

        return lifecycleResultMapper.toResponse(result);
    }

    @PostMapping("/{taskInstanceId}/complete")
    public TaskLifecycleResultResponse complete(
            @PathVariable UUID taskInstanceId,
            @RequestBody CompleteTaskRequest request
    ) {
        TaskLifecycleResult result = commandService.complete(
                request.getUserId(),
                taskInstanceId
        );

        return lifecycleResultMapper.toResponse(result);
    }

    @PostMapping("/{taskInstanceId}/reopen")
    public TaskLifecycleResultResponse reopen(
            @PathVariable UUID taskInstanceId,
            @RequestBody ReopenTaskRequest request
    ) {
        TaskLifecycleResult result = commandService.reopen(
                request.getUserId(),
                taskInstanceId,
                request.getReason()
        );

        return lifecycleResultMapper.toResponse(result);
    }

    @PostMapping("/{taskInstanceId}/reschedule")
    public TaskLifecycleResultResponse reschedule(
            @PathVariable UUID taskInstanceId,
            @RequestBody RescheduleTaskRequest request
    ) {
        TaskLifecycleResult result = commandService.reschedule(
                request.getUserId(),
                taskInstanceId,
                request.getTargetScheduledDate(),
                request.getTargetDueDateTime(),
                request.getReason()
        );

        return lifecycleResultMapper.toResponse(result);
    }

    @PostMapping("/future-occurrence/reschedule")
    public void rescheduleFutureOccurrence(
            @RequestBody RescheduleTaskRequest request
    ) {
        taskRescheduleService.rescheduleFutureOccurrence(
                request.getUserId(),
                request.getTemplateId(),
                request.getOccurrenceDate(),
                request.getTargetScheduledDate(),
                request.getTargetDueDateTime(),
                request.getReason()
        );
    }

    @PostMapping("/{taskInstanceId}/rollover")
    public TaskLifecycleResultResponse rollover(
            @PathVariable UUID taskInstanceId,
            @RequestBody RolloverTaskRequest request
    ) {
        TaskLifecycleResult result = commandService.rollover(
                request.getUserId(),
                taskInstanceId,
                request.getTargetScheduledDate(),
                request.getTargetDueDateTime(),
                request.getReason()
        );

        return lifecycleResultMapper.toResponse(result);
    }

    @PostMapping("/{taskInstanceId}/skip")
    public TaskLifecycleResultResponse skipExistingOccurrence(
            @PathVariable UUID taskInstanceId,
            @RequestBody SkipOccurrenceRequest request
    ) {
        TaskLifecycleResult result = commandService.skipExistingOccurrence(
                request.getUserId(),
                taskInstanceId,
                request.getReason()
        );

        return lifecycleResultMapper.toResponse(result);
    }

    @PostMapping("/occurrence/skip")
    public Object skipOccurrence(
            @RequestBody SkipOccurrenceRequest request
    ) {
        SkipOccurrenceResult result = commandService.skipOccurrence(
                request.getUserId(),
                request.getTemplateId(),
                request.getOccurrenceDate(),
                request.getReason()
        );

        if (result.existingInstance()) {
            return lifecycleResultMapper.toResponse(result.lifecycleResult());
        }

        return result.occurrenceException();
    }

    @PostMapping("/{taskInstanceId}/pause")
    public TaskLifecycleResultResponse pause(
            @PathVariable UUID taskInstanceId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return lifecycleResultMapper.toResponse(
                commandService.pause(
                        request.getUserId(),
                        taskInstanceId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/{taskInstanceId}/resume")
    public TaskLifecycleResultResponse resume(
            @PathVariable UUID taskInstanceId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return lifecycleResultMapper.toResponse(
                commandService.resume(
                        request.getUserId(),
                        taskInstanceId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/{taskInstanceId}/archive")
    public TaskLifecycleResultResponse archive(
            @PathVariable UUID taskInstanceId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return lifecycleResultMapper.toResponse(
                commandService.archive(
                        request.getUserId(),
                        taskInstanceId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/{taskInstanceId}/restore")
    public TaskLifecycleResultResponse restore(
            @PathVariable UUID taskInstanceId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return lifecycleResultMapper.toResponse(
                commandService.restore(
                        request.getUserId(),
                        taskInstanceId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/{taskInstanceId}/cancel")
    public TaskLifecycleResultResponse cancel(
            @PathVariable UUID taskInstanceId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return lifecycleResultMapper.toResponse(
                commandService.cancel(
                        request.getUserId(),
                        taskInstanceId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/{taskInstanceId}/clear-done")
    public TaskLifecycleResultResponse clearFromDone(
            @PathVariable UUID taskInstanceId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return lifecycleResultMapper.toResponse(
                commandService.clearFromDone(
                        request.getUserId(),
                        taskInstanceId
                )
        );
    }

    @PostMapping("/{taskInstanceId}/restore-done")
    public TaskLifecycleResultResponse restoreToDone(
            @PathVariable UUID taskInstanceId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return lifecycleResultMapper.toResponse(
                commandService.restoreToDone(
                        request.getUserId(),
                        taskInstanceId
                )
        );
    }

    @PostMapping("/done/clear")
    public DoneCleanupResult clearDoneForDay(
            @RequestParam UUID userId,
            @RequestParam LocalDate date
    ) {
        return commandService.clearDoneForDay(userId, date);
    }

    @PostMapping("/done/restore")
    public DoneCleanupResult restoreDoneForDay(
            @RequestParam UUID userId,
            @RequestParam LocalDate date
    ) {
        return commandService.restoreDoneForDay(userId, date);
    }

    @DeleteMapping("/{taskInstanceId}")
    public void delete(
            @PathVariable UUID taskInstanceId,
            @RequestParam UUID userId
    ) {
        commandService.delete(userId, taskInstanceId);
    }
}