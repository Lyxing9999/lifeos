package com.lifeos.backend.schedule.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.request.UpdateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleBlockRepository;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ScheduleBlockService {

    private final ScheduleBlockRepository repository;
    private final ScheduleBlockMapper mapper;

    public ScheduleBlockResponse create(CreateScheduleBlockRequest request) {
        validate(request.getStartTime().isBefore(request.getEndTime()), "startTime must be before endTime");

        ScheduleBlock block = mapper.toEntity(request);

        if (block.getRecurrenceStartDate() == null) {
            block.setRecurrenceStartDate(LocalDate.now());
        }

        validateRecurrence(block);

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

        validate(block.getStartTime().isBefore(block.getEndTime()), "startTime must be before endTime");
        validateRecurrence(block);

        return mapper.toResponse(repository.save(block));
    }

    public List<ScheduleBlockResponse> getByUser(UUID userId) {
        return repository.findByUserId(userId).stream()
                .map(mapper::toResponse)
                .toList();
    }

    public void delete(UUID scheduleBlockId) {
        repository.deleteById(scheduleBlockId);
    }

    private void validateRecurrence(ScheduleBlock block) {
        ScheduleRecurrenceType recurrenceType = block.getRecurrenceType();

        if (recurrenceType == ScheduleRecurrenceType.CUSTOM_WEEKLY) {
            validate(block.getRecurrenceDaysOfWeek() != null && !block.getRecurrenceDaysOfWeek().isBlank(),
                    "recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }

        if (block.getRecurrenceEndDate() != null) {
            validate(!block.getRecurrenceEndDate().isBefore(block.getRecurrenceStartDate()),
                    "recurrenceEndDate must be on or after recurrenceStartDate");
        }
    }

    private void validate(boolean condition, String message) {
        if (!condition) {
            throw new IllegalArgumentException(message);
        }
    }
}