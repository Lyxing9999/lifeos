package com.lifeos.backend.task.api;

import com.lifeos.backend.auth.domain.LifeOsPrincipal;
import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.request.UpdateTaskRequest;
import com.lifeos.backend.task.api.response.TaskOverviewBffResponse;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.api.response.TaskSectionResponse;
import com.lifeos.backend.task.api.response.TaskSurfaceBffResponse;
import com.lifeos.backend.task.application.TaskBffService;
import com.lifeos.backend.task.application.TaskCommandService;
import com.lifeos.backend.task.application.TaskQueryService;
import com.lifeos.backend.task.domain.enums.TaskFilterType;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/tasks")
@RequiredArgsConstructor
public class TaskController {

        private final TaskCommandService taskCommandService;
        private final TaskQueryService taskQueryService;
        private final TaskBffService taskBffService;

        @PostMapping
        public ApiResponse<TaskResponse> create(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @Valid @RequestBody CreateTaskRequest request) {
                request.setUserId(requireUserId(principal));

                return ApiResponse.success(
                                taskCommandService.create(request),
                                "Task created");
        }

        @PatchMapping("/{taskId}")
        public ApiResponse<TaskResponse> update(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @PathVariable UUID taskId,
                        @RequestBody UpdateTaskRequest request) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskCommandService.update(userId, taskId, request),
                                "Task updated");
        }

        @PostMapping("/{taskId}/complete")
        public ApiResponse<TaskResponse> complete(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @PathVariable UUID taskId,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskCommandService.complete(userId, taskId, date),
                                "Task completed");
        }

        @PostMapping("/{taskId}/reopen")
        public ApiResponse<TaskResponse> reopen(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @PathVariable UUID taskId,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskCommandService.reopen(userId, taskId, date),
                                "Task reopened");
        }

        @PostMapping("/{taskId}/archive")
        public ApiResponse<TaskResponse> archive(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @PathVariable UUID taskId) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskCommandService.archive(userId, taskId),
                                "Task archived");
        }

        @PostMapping("/{taskId}/restore")
        public ApiResponse<TaskResponse> restore(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @PathVariable UUID taskId) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskCommandService.restore(userId, taskId),
                                "Task restored");
        }

        @PostMapping("/{taskId}/pause")
        public ApiResponse<TaskResponse> pause(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @PathVariable UUID taskId,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate until) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskCommandService.pause(userId, taskId, until),
                                "Task paused");
        }

        @PostMapping("/{taskId}/resume")
        public ApiResponse<TaskResponse> resume(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @PathVariable UUID taskId) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskCommandService.resume(userId, taskId),
                                "Task resumed");
        }

        @PostMapping("/me/done/clear")
        public ApiResponse<Void> clearMyDoneForDay(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
                UUID userId = requireUserId(principal);

                taskCommandService.clearDoneForDay(userId, date);

                return ApiResponse.success(null, "Done list cleared");
        }

        @DeleteMapping("/{taskId}")
        public ApiResponse<Void> delete(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @PathVariable UUID taskId) {
                UUID userId = requireUserId(principal);

                taskCommandService.delete(userId, taskId);

                return ApiResponse.success(null, "Task deleted");
        }

        /**
         * Active task library.
         * Product meaning:
         * - active tasks only
         * - not completed
         * - not archived
         * - not paused
         * Completed work belongs to /me/history.
         * Archived work belongs to /me/archived.
         */
        @GetMapping("/me")
        public ApiResponse<List<TaskResponse>> getMyTasks(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @RequestParam(defaultValue = "ACTIVE") String filter) {
                UUID userId = requireUserId(principal);
                TaskFilterType parsedFilter = TaskFilterType.from(filter, TaskFilterType.ACTIVE);
                if (parsedFilter == TaskFilterType.ARCHIVED) {
                        return ApiResponse.success(
                                        taskQueryService.getArchivedTasks(userId, TaskFilterType.ALL));
                }
                if (parsedFilter == TaskFilterType.COMPLETED) {
                        throw new IllegalArgumentException(
                                        "Use /api/v1/tasks/me/history?date=YYYY-MM-DD for completed tasks");
                }
                return ApiResponse.success(
                                taskQueryService.getAllActiveTasks(userId));
        }

        /**
         * Day workflow.
         *
         * ACTIVE = active committed tasks for selected day
         * COMPLETED = Done tab; hides Done-cleared tasks
         * ALL = day truth; does not hide Done-cleared tasks
         */
        @GetMapping("/me/day")
        public ApiResponse<List<TaskResponse>> getMyRelevantTasksByDay(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
                        @RequestParam(defaultValue = "ALL") String filter) {
                UUID userId = requireUserId(principal);
                TaskFilterType parsedFilter = TaskFilterType.from(filter, TaskFilterType.ALL);

                if (parsedFilter == TaskFilterType.ARCHIVED) {
                        parsedFilter = TaskFilterType.ALL;
                }

                return ApiResponse.success(
                                taskQueryService.getRelevantTasksByUserAndDay(userId, date, parsedFilter));
        }

        @GetMapping("/me/sections")
        public ApiResponse<TaskSectionResponse> getMySectionsForDay(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
                        @RequestParam(defaultValue = "ALL") String filter) {
                UUID userId = requireUserId(principal);
                TaskFilterType parsedFilter = TaskFilterType.from(filter, TaskFilterType.ALL);

                if (parsedFilter == TaskFilterType.ARCHIVED) {
                        parsedFilter = TaskFilterType.ALL;
                }

                return ApiResponse.success(
                                taskQueryService.getSectionsForDay(userId, date, parsedFilter));
        }

        @GetMapping("/me/inbox")
        public ApiResponse<List<TaskResponse>> getMyInboxTasks(
                        @AuthenticationPrincipal LifeOsPrincipal principal) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskQueryService.getInboxTasks(userId));
        }

        @GetMapping("/me/history")
        public ApiResponse<List<TaskResponse>> getMyCompletedHistory(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskQueryService.getCompletedHistoryForDay(userId, date));
        }

        @GetMapping("/me/paused")
        public ApiResponse<List<TaskResponse>> getMyPausedTasks(
                        @AuthenticationPrincipal LifeOsPrincipal principal) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskQueryService.getPausedTasks(userId));
        }

        @GetMapping("/me/archived")
        public ApiResponse<List<TaskResponse>> getMyArchivedTasks(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @RequestParam(defaultValue = "ALL") String filter) {
                UUID userId = requireUserId(principal);
                TaskFilterType parsedFilter = TaskFilterType.from(filter, TaskFilterType.ALL);

                return ApiResponse.success(
                                taskQueryService.getArchivedTasks(userId, parsedFilter));
        }

        @GetMapping("/me/surfaces")
        public ApiResponse<TaskSurfaceBffResponse> getMySurfaces(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
                        @RequestParam(defaultValue = "ACTIVE") String filter) {
                UUID userId = requireUserId(principal);
                TaskFilterType parsedFilter = TaskFilterType.from(filter, TaskFilterType.ACTIVE);

                return ApiResponse.success(
                                taskBffService.getSurfaces(userId, date, parsedFilter));
        }

        @GetMapping("/me/overview")
        public ApiResponse<TaskOverviewBffResponse> getMyOverview(
                        @AuthenticationPrincipal LifeOsPrincipal principal,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
                UUID userId = requireUserId(principal);

                return ApiResponse.success(
                                taskBffService.getOverview(userId, date));
        }

        private UUID requireUserId(LifeOsPrincipal principal) {
                if (principal == null || principal.userId() == null) {
                        throw new IllegalStateException("Authentication required");
                }

                return principal.userId();
        }

        @GetMapping("/{taskId}")
        public ApiResponse<TaskResponse> getById(
                @AuthenticationPrincipal LifeOsPrincipal principal,
                @PathVariable UUID taskId,
                @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
                UUID userId = requireUserId(principal);
                return ApiResponse.success(
                        taskQueryService.getByIdForUser(userId, taskId, date));
        }
}