package com.lifeos.backend.schedule.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.api.response.ScheduleSelectOptionResponse;
import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleBlockRepository;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import com.lifeos.backend.schedule.domain.service.ScheduleRecurrenceResolver;
import com.lifeos.backend.schedule.infrastructure.ScheduleBlockMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScheduleQueryService {

    private final ScheduleBlockRepository repository;
    private final ScheduleBlockMapper mapper;
    private final ScheduleRecurrenceResolver recurrenceResolver;

    // --- TIMELINE / OCCURRENCES ---

    public List<ScheduleOccurrenceResponse> getOccurrencesForDay(UUID userId, LocalDate date) {
        return repository.findUnarchivedByUserId(userId).stream()
                .filter(block -> block.isActiveBlock() && isNotExpired(block, date) && recurrenceResolver.occursOn(block, date))
                .map(block -> ScheduleOccurrenceResponse.builder()
                        .scheduleBlockId(block.getId())
                        .userId(block.getUserId())
                        .title(block.getTitle())
                        .type(block.getType())
                        .recurrenceType(block.getRecurrenceType())
                        .occurrenceDate(date)
                        .startDateTime(date.atTime(block.getStartTime()))
                        .endDateTime(date.atTime(block.getEndTime()))
                        .build())
                .sorted(Comparator.comparing(ScheduleOccurrenceResponse::getStartDateTime))
                .toList();
    }

    // --- MANAGEMENT SURFACES (ACTIVE / INACTIVE) ---

    public List<ScheduleBlockResponse> getActiveBlocks(UUID userId, LocalDate today) {
        return repository.findUnarchivedByUserId(userId).stream()
                .filter(ScheduleBlock::isActiveBlock)
                .filter(block -> isNotExpired(block, today)) // Drop dead schedules
                .map(mapper::toResponse)
                .toList();
    }

    public List<ScheduleBlockResponse> getInactiveBlocks(UUID userId, LocalDate today) {
        return repository.findUnarchivedByUserId(userId).stream()
                .filter(block -> !block.isActiveBlock()) // Paused by user
                .filter(block -> isNotExpired(block, today)) // Drop dead schedules
                .map(mapper::toResponse)
                .toList();
    }

    // --- THE GRAVEYARD (HISTORY) ---

    public List<ScheduleBlockResponse> getHistoryBlocks(UUID userId, LocalDate today) {
        // 1. Get the ones explicitly deleted/archived by user or job
        List<ScheduleBlock> history = new java.util.ArrayList<>(repository.findArchivedByUserId(userId));

        // 2. Get the ones that dynamically expired (time passed them by)
        List<ScheduleBlock> dynamicallyExpired = repository.findUnarchivedByUserId(userId).stream()
                .filter(block -> !isNotExpired(block, today))
                .toList();

        history.addAll(dynamicallyExpired);

        return history.stream()
                .map(mapper::toResponse)
                .toList();
    }

    // --- UTILS ---

    public List<ScheduleSelectOptionResponse> getActiveSelectOptions(UUID userId, LocalDate today) {
        return repository.findUnarchivedByUserId(userId).stream()
                .filter(block -> block.isActiveBlock() && isNotExpired(block, today) && recurrenceResolver.occursOn(block, today))
                .map(mapper::toSelectOption)
                .toList();
    }

    public ScheduleBlockResponse getByIdForUser(UUID userId, UUID scheduleBlockId) {
        ScheduleBlock block = repository.findById(scheduleBlockId)
                .orElseThrow(() -> new NotFoundException("Schedule block not found"));

        if (!block.getUserId().equals(userId)) throw new NotFoundException("Schedule block not found");
        return mapper.toResponse(block);
    }
    private boolean isNotExpired(ScheduleBlock block, LocalDate today) {
        // EDGE CASE FIX: If it only happens "Once", it expires immediately after its start date.
        if (block.getRecurrenceType() == ScheduleRecurrenceType.NONE) {
            return !block.getRecurrenceStartDate().isBefore(today);
        }

        // NORMAL RECURRENCE:
        if (block.getRecurrenceEndDate() == null) {
            return true; // No end date means it repeats forever
        }

        // If it has an end date, check if it has passed
        return !block.getRecurrenceEndDate().isBefore(today);
    }
}