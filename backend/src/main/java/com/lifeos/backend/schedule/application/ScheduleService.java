package com.lifeos.backend.schedule.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.request.UpdateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleBlockRepository;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ScheduleService {

    private final ScheduleBlockRepository repository;
    private final ScheduleBlockMapper mapper;
    private final ScheduleRecurrenceResolver recurrenceResolver;

    public ScheduleBlockResponse create(CreateScheduleBlockRequest request) {
        validateCreateOrUpdate(
                request.getStartTime(),
                request.getEndTime(),
                request.getRecurrenceType(),
                request.getRecurrenceDaysOfWeek(),
                request.getRecurrenceStartDate(),
                request.getRecurrenceEndDate()
        );

        ScheduleBlock block = mapper.toEntity(request);

        if (block.getRecurrenceStartDate() == null) {
            block.setRecurrenceStartDate(LocalDate.now());
        }

        return mapper.toResponse(repository.save(block));
    }

    public ScheduleBlockResponse update(UUID scheduleBlockId, UpdateScheduleBlockRequest request) {
        ScheduleBlock block = repository.findById(scheduleBlockId)
                .orElseThrow(() -> new NotFoundException("Schedule block not found"));

        if (request.getTitle() != null) block.setTitle(request.getTitle());
        if (request.getType() != null) block.setType(request.getType());
        if (request.getDescription() != null) block.setDescription(request.getDescription());
        if (request.getStartTime() != null) block.setStartTime(request.getStartTime());
        if (request.getEndTime() != null) block.setEndTime(request.getEndTime());
        if (request.getRecurrenceType() != null) block.setRecurrenceType(request.getRecurrenceType());
        if (request.getRecurrenceDaysOfWeek() != null) block.setRecurrenceDaysOfWeek(request.getRecurrenceDaysOfWeek());
        if (request.getRecurrenceStartDate() != null) block.setRecurrenceStartDate(request.getRecurrenceStartDate());
        if (request.getRecurrenceEndDate() != null) block.setRecurrenceEndDate(request.getRecurrenceEndDate());
        if (request.getActive() != null) block.setActive(request.getActive());

        validateCreateOrUpdate(
                block.getStartTime(),
                block.getEndTime(),
                block.getRecurrenceType(),
                block.getRecurrenceDaysOfWeek(),
                block.getRecurrenceStartDate(),
                block.getRecurrenceEndDate()
        );

        return mapper.toResponse(repository.save(block));
    }

    public ScheduleBlockResponse getById(UUID scheduleBlockId) {
        ScheduleBlock block = repository.findById(scheduleBlockId)
                .orElseThrow(() -> new NotFoundException("Schedule block not found"));
        return mapper.toResponse(block);
    }

    public List<ScheduleBlockResponse> getByUser(UUID userId) {
        return repository.findByUserId(userId).stream()
                .sorted(Comparator.comparing(ScheduleBlock::getStartTime))
                .map(mapper::toResponse)
                .toList();
    }

    public List<ScheduleOccurrenceResponse> getOccurrencesByUserIdAndDay(UUID userId, LocalDate date) {
        List<ScheduleBlock> activeBlocks = repository.findByUserId(userId).stream()
                .filter(block -> !Boolean.FALSE.equals(block.getActive()))
                .toList();

        System.out.println("schedule_debug userId=" + userId + " date=" + date + " activeBlocks=" + activeBlocks.size());

        activeBlocks.forEach(block -> System.out.println(
                "schedule_block title=" + block.getTitle()
                        + ", recurrenceType=" + block.getRecurrenceType()
                        + ", recurrenceDaysOfWeek=" + block.getRecurrenceDaysOfWeek()
                        + ", recurrenceStartDate=" + block.getRecurrenceStartDate()
                        + ", recurrenceEndDate=" + block.getRecurrenceEndDate()
                        + ", active=" + block.getActive()
                        + ", occursOn=" + recurrenceResolver.occursOn(block, date)
        ));

        return activeBlocks.stream()
                .filter(block -> recurrenceResolver.occursOn(block, date))
                .map(block -> ScheduleOccurrenceResponse.builder()
                        .scheduleBlockId(block.getId())
                        .userId(block.getUserId())
                        .title(block.getTitle())
                        .type(block.getType())
                        .occurrenceDate(date)
                        .startDateTime(date.atTime(block.getStartTime()))
                        .endDateTime(date.atTime(block.getEndTime()))
                        .build())
                .sorted(Comparator.comparing(ScheduleOccurrenceResponse::getStartDateTime))
                .toList();
    }

    public void deactivate(UUID scheduleBlockId) {
        ScheduleBlock block = repository.findById(scheduleBlockId)
                .orElseThrow(() -> new NotFoundException("Schedule block not found"));
        block.setActive(false);
        repository.save(block);
    }

    public void delete(UUID scheduleBlockId) {
        repository.deleteById(scheduleBlockId);
    }

    private void validateCreateOrUpdate(
            java.time.LocalTime startTime,
            java.time.LocalTime endTime,
            ScheduleRecurrenceType recurrenceType,
            String recurrenceDaysOfWeek,
            LocalDate recurrenceStartDate,
            LocalDate recurrenceEndDate
    ) {
        if (startTime == null || endTime == null) {
            throw new IllegalArgumentException("startTime and endTime are required");
        }

        if (!startTime.isBefore(endTime)) {
            throw new IllegalArgumentException("startTime must be before endTime");
        }

        if (recurrenceStartDate == null) {
            throw new IllegalArgumentException("recurrenceStartDate is required");
        }

        if (recurrenceEndDate != null && recurrenceEndDate.isBefore(recurrenceStartDate)) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }

        if (recurrenceType == ScheduleRecurrenceType.CUSTOM_WEEKLY &&
                (recurrenceDaysOfWeek == null || recurrenceDaysOfWeek.isBlank())) {
            throw new IllegalArgumentException("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }
    }
}