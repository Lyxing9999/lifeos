package com.lifeos.backend.schedule.application.query;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.repository.ScheduleTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.UUID;

/**
 * Read-side service for ScheduleTemplate.
 *
 * ScheduleTemplate = future/recurring planned time blueprint.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScheduleTemplateQueryService {

    private final ScheduleTemplateRepository templateRepository;

    public ScheduleTemplate getByIdForUser(UUID userId, UUID templateId) {
        validateUserId(userId);
        validateTemplateId(templateId);

        return templateRepository.findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Schedule template not found"));
    }

    public List<ScheduleTemplate> getAllForUser(UUID userId) {
        validateUserId(userId);

        return templateRepository.findByUserId(userId)
                .stream()
                .sorted(templateComparator())
                .toList();
    }

    public List<ScheduleTemplate> getActiveForUser(UUID userId) {
        validateUserId(userId);

        return templateRepository.findActiveByUserId(userId)
                .stream()
                .sorted(templateComparator())
                .toList();
    }

    public List<ScheduleTemplate> getPausedForUser(UUID userId) {
        validateUserId(userId);

        return templateRepository.findPausedByUserId(userId)
                .stream()
                .sorted(templateComparator())
                .toList();
    }

    public List<ScheduleTemplate> getArchivedForUser(UUID userId) {
        validateUserId(userId);

        return templateRepository.findArchivedByUserId(userId)
                .stream()
                .sorted(templateComparator())
                .toList();
    }

    public List<ScheduleTemplate> getActiveAndPausedForUser(UUID userId) {
        validateUserId(userId);

        return templateRepository.findByUserId(userId)
                .stream()
                .filter(template -> template.isActiveTemplate() || template.isPaused())
                .sorted(templateComparator())
                .toList();
    }

    public List<ScheduleTemplate> getRecurringForUser(UUID userId) {
        validateUserId(userId);

        return templateRepository.findByUserId(userId)
                .stream()
                .filter(ScheduleTemplate::isRecurring)
                .sorted(templateComparator())
                .toList();
    }

    public List<ScheduleTemplate> getActiveRecurringForUser(UUID userId) {
        validateUserId(userId);

        return templateRepository.findActiveByUserId(userId)
                .stream()
                .filter(ScheduleTemplate::isRecurring)
                .sorted(templateComparator())
                .toList();
    }

    public List<ScheduleTemplate> getOneTimeForUser(UUID userId) {
        validateUserId(userId);

        return templateRepository.findByUserId(userId)
                .stream()
                .filter(ScheduleTemplate::isOneTime)
                .sorted(templateComparator())
                .toList();
    }

    private Comparator<ScheduleTemplate> templateComparator() {
        return Comparator
                .comparing(ScheduleTemplate::getStartTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(ScheduleTemplate::getEndTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(ScheduleTemplate::getTitle, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateTemplateId(UUID templateId) {
        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }
    }
}