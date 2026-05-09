package com.lifeos.backend.schedule.api;

import com.lifeos.backend.schedule.api.request.CreateScheduleOccurrenceRequest;
import com.lifeos.backend.schedule.api.request.RescheduleScheduleOccurrenceRequest;
import com.lifeos.backend.schedule.api.request.ScheduleReasonRequest;
import com.lifeos.backend.schedule.api.request.SkipScheduleOccurrenceRequest;
import com.lifeos.backend.schedule.api.response.ScheduleAvailabilityResponse;
import com.lifeos.backend.schedule.api.response.ScheduleExceptionResponse;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.application.command.ScheduleOccurrenceCommandService;
import com.lifeos.backend.schedule.application.command.ScheduleRescheduleService;
import com.lifeos.backend.schedule.application.command.ScheduleSkipService;
import com.lifeos.backend.schedule.application.query.ScheduleAvailabilityQueryService;
import com.lifeos.backend.schedule.application.query.ScheduleOccurrenceQueryService;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.valueobject.AvailabilityWindow;
import com.lifeos.backend.schedule.infrastructure.mapper.ScheduleAvailabilityMapper;
import com.lifeos.backend.schedule.infrastructure.mapper.ScheduleExceptionMapper;
import com.lifeos.backend.schedule.infrastructure.mapper.ScheduleOccurrenceMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/schedule-occurrences")
@RequiredArgsConstructor
public class ScheduleOccurrenceController {

    private final ScheduleOccurrenceCommandService commandService;
    private final ScheduleRescheduleService rescheduleService;
    private final ScheduleSkipService skipService;

    private final ScheduleOccurrenceQueryService queryService;
    private final ScheduleAvailabilityQueryService availabilityQueryService;

    private final ScheduleOccurrenceMapper occurrenceMapper;
    private final ScheduleExceptionMapper exceptionMapper;
    private final ScheduleAvailabilityMapper availabilityMapper;

    @PostMapping
    public ScheduleOccurrenceResponse createManual(
            @RequestBody CreateScheduleOccurrenceRequest request
    ) {
        ScheduleOccurrence created = commandService.createManual(
                new ScheduleOccurrenceCommandService.CreateScheduleOccurrenceCommand(
                        request.getUserId(),
                        request.getTitle(),
                        request.getDescription(),
                        request.getType(),
                        request.getStartDateTime(),
                        request.getEndDateTime(),
                        request.getLinkedTaskInstanceId(),
                        request.getLinkedTaskTemplateId()
                )
        );

        return occurrenceMapper.toResponse(created);
    }

    @GetMapping("/{occurrenceId}")
    public ScheduleOccurrenceResponse getById(
            @PathVariable UUID occurrenceId,
            @RequestParam UUID userId
    ) {
        return occurrenceMapper.toResponse(
                queryService.getByIdForUser(userId, occurrenceId)
        );
    }

    @GetMapping("/day")
    public List<ScheduleOccurrenceResponse> getOccurrencesForDay(
            @RequestParam UUID userId,
            @RequestParam LocalDate date,
            @RequestParam(defaultValue = "VISIBLE") String view
    ) {
        List<ScheduleOccurrence> occurrences = switch (view.trim().toUpperCase()) {
            case "ALL" -> queryService.getOccurrencesForDay(userId, date);
            case "TIMELINE" -> queryService.getTimelineOccurrencesForDay(userId, date);
            default -> queryService.getVisibleOccurrencesForDay(userId, date);
        };

        return occurrences.stream()
                .map(occurrenceMapper::toResponse)
                .toList();
    }

    @GetMapping("/range")
    public List<ScheduleOccurrenceResponse> getOccurrencesByRange(
            @RequestParam UUID userId,
            @RequestParam LocalDate startDate,
            @RequestParam LocalDate endDate,
            @RequestParam(defaultValue = "VISIBLE") String view
    ) {
        List<ScheduleOccurrence> occurrences = switch (view.trim().toUpperCase()) {
            case "ALL" -> queryService.getOccurrencesByDateRange(
                    userId,
                    startDate,
                    endDate
            );
            default -> queryService.getVisibleOccurrencesByDateRange(
                    userId,
                    startDate,
                    endDate
            );
        };

        return occurrences.stream()
                .map(occurrenceMapper::toResponse)
                .toList();
    }

    @GetMapping("/status/{status}")
    public List<ScheduleOccurrenceResponse> getByStatus(
            @RequestParam UUID userId,
            @PathVariable com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus status
    ) {
        return queryService.getByStatus(userId, status)
                .stream()
                .map(occurrenceMapper::toResponse)
                .toList();
    }

    @GetMapping("/overlap")
    public List<ScheduleOccurrenceResponse> getOverlapping(
            @RequestParam UUID userId,
            @RequestParam LocalDateTime startDateTime,
            @RequestParam LocalDateTime endDateTime
    ) {
        return queryService.getOverlapping(
                        userId,
                        startDateTime,
                        endDateTime
                )
                .stream()
                .map(occurrenceMapper::toResponse)
                .toList();
    }

    @GetMapping("/availability/day")
    public ScheduleAvailabilityResponse getAvailabilityForDay(
            @RequestParam UUID userId,
            @RequestParam LocalDate date,
            @RequestParam(required = false) LocalTime dayStartTime,
            @RequestParam(required = false) LocalTime dayEndTime,
            @RequestParam(defaultValue = "1") long minimumMinutes
    ) {
        List<AvailabilityWindow> windows =
                availabilityQueryService.getAvailabilityForDay(
                        userId,
                        date,
                        dayStartTime,
                        dayEndTime,
                        minimumMinutes
                );

        return availabilityMapper.toAvailabilityResponse(
                userId,
                date,
                dayStartTime == null ? null : date.atTime(dayStartTime),
                dayEndTime == null ? null : date.atTime(dayEndTime),
                windows
        );
    }

    @GetMapping("/availability/range")
    public ScheduleAvailabilityResponse getAvailabilityBetween(
            @RequestParam UUID userId,
            @RequestParam LocalDateTime rangeStart,
            @RequestParam LocalDateTime rangeEnd,
            @RequestParam(defaultValue = "1") long minimumMinutes
    ) {
        List<AvailabilityWindow> windows =
                availabilityQueryService.getAvailabilityBetween(
                        userId,
                        rangeStart,
                        rangeEnd,
                        minimumMinutes
                );

        return availabilityMapper.toAvailabilityResponse(
                userId,
                rangeStart.toLocalDate(),
                rangeStart,
                rangeEnd,
                windows
        );
    }

    @GetMapping("/availability/check")
    public ScheduleAvailabilityResponse checkAvailability(
            @RequestParam UUID userId,
            @RequestParam LocalDateTime startDateTime,
            @RequestParam LocalDateTime endDateTime
    ) {
        return availabilityMapper.toCheckResponse(
                availabilityQueryService.checkAvailability(
                        userId,
                        startDateTime,
                        endDateTime
                )
        );
    }

    @PostMapping("/{occurrenceId}/activate")
    public ScheduleOccurrenceResponse activate(
            @PathVariable UUID occurrenceId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return occurrenceMapper.toResponse(
                commandService.activate(
                        request.getUserId(),
                        occurrenceId
                )
        );
    }

    @PostMapping("/{occurrenceId}/expire")
    public ScheduleOccurrenceResponse expire(
            @PathVariable UUID occurrenceId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return occurrenceMapper.toResponse(
                commandService.expire(
                        request.getUserId(),
                        occurrenceId
                )
        );
    }

    @PostMapping("/{occurrenceId}/cancel")
    public ScheduleOccurrenceResponse cancelExisting(
            @PathVariable UUID occurrenceId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return occurrenceMapper.toResponse(
                commandService.cancel(
                        request.getUserId(),
                        occurrenceId
                )
        );
    }

    @PostMapping("/{occurrenceId}/restore-planned")
    public ScheduleOccurrenceResponse restoreToPlanned(
            @PathVariable UUID occurrenceId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return occurrenceMapper.toResponse(
                commandService.restoreToPlanned(
                        request.getUserId(),
                        occurrenceId
                )
        );
    }

    @PostMapping("/{occurrenceId}/reschedule")
    public ScheduleRescheduleResponse rescheduleExisting(
            @PathVariable UUID occurrenceId,
            @RequestBody RescheduleScheduleOccurrenceRequest request
    ) {
        ScheduleRescheduleService.ScheduleRescheduleResult result =
                rescheduleService.rescheduleExistingOccurrence(
                        request.getUserId(),
                        occurrenceId,
                        request.getTargetStartDateTime(),
                        request.getTargetEndDateTime(),
                        request.getReason()
                );

        return new ScheduleRescheduleResponse(
                occurrenceMapper.toResponse(result.sourceOccurrence()),
                occurrenceMapper.toResponse(result.targetOccurrence())
        );
    }

    @PostMapping("/future/reschedule")
    public ScheduleExceptionResponse rescheduleFutureOccurrence(
            @RequestBody RescheduleScheduleOccurrenceRequest request
    ) {
        return exceptionMapper.toResponse(
                rescheduleService.rescheduleFutureOccurrence(
                        request.getUserId(),
                        request.getTemplateId(),
                        request.getOccurrenceDate(),
                        request.getTargetStartDateTime(),
                        request.getTargetEndDateTime(),
                        request.getReason()
                )
        );
    }

    @PostMapping("/{occurrenceId}/skip")
    public ScheduleOccurrenceResponse skipExisting(
            @PathVariable UUID occurrenceId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return occurrenceMapper.toResponse(
                skipService.skipExistingOccurrence(
                        request.getUserId(),
                        occurrenceId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/future/skip")
    public ScheduleExceptionResponse skipFutureOccurrence(
            @RequestBody SkipScheduleOccurrenceRequest request
    ) {
        return exceptionMapper.toResponse(
                skipService.skipFutureOccurrence(
                        request.getUserId(),
                        request.getTemplateId(),
                        request.getOccurrenceDate(),
                        request.getReason()
                )
        );
    }

    @PostMapping("/occurrence/skip")
    public ScheduleSkipResultResponse skipOccurrence(
            @RequestBody SkipScheduleOccurrenceRequest request
    ) {
        ScheduleSkipService.ScheduleSkipResult result =
                skipService.skipOccurrence(
                        request.getUserId(),
                        request.getTemplateId(),
                        request.getOccurrenceDate(),
                        request.getReason()
                );

        return toSkipResultResponse(result);
    }

    @PostMapping("/future/cancel")
    public ScheduleExceptionResponse cancelFutureOccurrence(
            @RequestBody SkipScheduleOccurrenceRequest request
    ) {
        return exceptionMapper.toResponse(
                skipService.cancelFutureOccurrence(
                        request.getUserId(),
                        request.getTemplateId(),
                        request.getOccurrenceDate(),
                        request.getReason()
                )
        );
    }

    @PostMapping("/occurrence/cancel")
    public ScheduleSkipResultResponse cancelOccurrence(
            @RequestBody SkipScheduleOccurrenceRequest request
    ) {
        ScheduleSkipService.ScheduleSkipResult result =
                skipService.cancelOccurrence(
                        request.getUserId(),
                        request.getTemplateId(),
                        request.getOccurrenceDate(),
                        request.getReason()
                );

        return toSkipResultResponse(result);
    }

    @DeleteMapping("/{occurrenceId}")
    public void delete(
            @PathVariable UUID occurrenceId,
            @RequestParam UUID userId
    ) {
        commandService.delete(userId, occurrenceId);
    }

    private ScheduleSkipResultResponse toSkipResultResponse(
            ScheduleSkipService.ScheduleSkipResult result
    ) {
        if (result == null) {
            return null;
        }

        return new ScheduleSkipResultResponse(
                result.existingOccurrence(),
                occurrenceMapper.toResponse(result.occurrence()),
                exceptionMapper.toResponse(result.exception())
        );
    }

    public record ScheduleRescheduleResponse(
            ScheduleOccurrenceResponse sourceOccurrence,
            ScheduleOccurrenceResponse targetOccurrence
    ) {
    }

    public record ScheduleSkipResultResponse(
            boolean existingOccurrence,
            ScheduleOccurrenceResponse occurrence,
            ScheduleExceptionResponse exception
    ) {
    }
}