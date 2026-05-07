package com.lifeos.backend.schedule.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.request.UpdateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleBlockRepository;
import com.lifeos.backend.schedule.domain.policy.ScheduleValidationPolicy;
import com.lifeos.backend.schedule.infrastructure.ScheduleBlockMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class ScheduleCommandService {

    private final ScheduleBlockRepository repository;
    private final ScheduleBlockMapper mapper;
    private final ScheduleValidationPolicy validationPolicy;

    public ScheduleBlockResponse create(UUID userId, CreateScheduleBlockRequest request) {
        ScheduleBlock block = mapper.toEntity(request);
        block.setUserId(userId);
        if (block.getRecurrenceStartDate() == null) block.setRecurrenceStartDate(LocalDate.now());

        validationPolicy.validateForCreateOrUpdate(block);
        return mapper.toResponse(repository.save(block));
    }

    public ScheduleBlockResponse update(UUID userId, UUID scheduleBlockId, UpdateScheduleBlockRequest request) {
        ScheduleBlock block = getOwnedBlockOrThrow(userId, scheduleBlockId);

        if (request.getTitle() != null) block.setTitle(request.getTitle());
        if (request.getType() != null) block.setType(request.getType());
        if (request.getDescription() != null) block.setDescription(request.getDescription());
        if (request.getStartTime() != null) block.setStartTime(request.getStartTime());
        if (request.getEndTime() != null) block.setEndTime(request.getEndTime());
        if (request.getRecurrenceType() != null) block.setRecurrenceType(request.getRecurrenceType());
        if (request.getRecurrenceDaysOfWeek() != null) block.setRecurrenceDaysOfWeek(request.getRecurrenceDaysOfWeek());
        if (request.getRecurrenceStartDate() != null) block.setRecurrenceStartDate(request.getRecurrenceStartDate());
        if (request.getRecurrenceEndDate() != null) block.setRecurrenceEndDate(request.getRecurrenceEndDate());

        if (request.getActive() != null) {
            if (request.getActive()) block.activate();
            else block.deactivate();
        }

        validationPolicy.validateForCreateOrUpdate(block);
        return mapper.toResponse(repository.save(block));
    }

    public ScheduleBlockResponse deactivate(UUID userId, UUID scheduleBlockId) {
        ScheduleBlock block = getOwnedBlockOrThrow(userId, scheduleBlockId);
        block.deactivate();
        return mapper.toResponse(repository.save(block));
    }

    public ScheduleBlockResponse activate(UUID userId, UUID scheduleBlockId) {
        ScheduleBlock block = getOwnedBlockOrThrow(userId, scheduleBlockId);
        block.activate();
        validationPolicy.validateForCreateOrUpdate(block);
        return mapper.toResponse(repository.save(block));
    }

    public void delete(UUID userId, UUID scheduleBlockId) {
        getOwnedBlockOrThrow(userId, scheduleBlockId);
        repository.deleteById(scheduleBlockId);
    }

    private ScheduleBlock getOwnedBlockOrThrow(UUID userId, UUID scheduleBlockId) {
        ScheduleBlock block = repository.findById(scheduleBlockId)
                .orElseThrow(() -> new NotFoundException("Schedule block not found"));
        if (!userId.equals(block.getUserId())) throw new NotFoundException("Schedule block not found");
        return block;
    }
}