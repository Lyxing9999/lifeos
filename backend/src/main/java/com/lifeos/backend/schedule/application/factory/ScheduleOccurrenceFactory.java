package com.lifeos.backend.schedule.application.factory;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.enums.ScheduleSourceType;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Creates ScheduleOccurrence objects.
 *
 * This factory does not save to database.
 * Persistence belongs to command/spawner services.
 */
@Component
public class ScheduleOccurrenceFactory {

    /**
     * Create a manual one-off schedule occurrence.
     *
     * Example:
     * User creates: "Doctor appointment 2 PM - 3 PM"
     */
    public ScheduleOccurrence createManual(
            UUID userId,
            String title,
            ScheduleBlockType type,
            String description,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            UUID linkedTaskInstanceId,
            UUID linkedTaskTemplateId,
            LocalDateTime userNowLocal
    ) {
        validateUserId(userId);
        validateTitle(title);
        validateTimeWindow(startDateTime, endDateTime);

        ScheduleOccurrence occurrence = new ScheduleOccurrence();

        occurrence.setUserId(userId);
        occurrence.setTemplateId(null);

        occurrence.setTitleSnapshot(title.trim());
        occurrence.setTypeSnapshot(type == null ? ScheduleBlockType.OTHER : type);
        occurrence.setDescriptionSnapshot(normalize(description));

        occurrence.setOccurrenceDate(startDateTime.toLocalDate());
        occurrence.setScheduledDate(startDateTime.toLocalDate());

        occurrence.setStartDateTime(startDateTime);
        occurrence.setEndDateTime(endDateTime);

        occurrence.setStatus(resolveInitialStatus(startDateTime, endDateTime, userNowLocal));
        occurrence.setPreviousStatus(null);

        occurrence.setSourceType(ScheduleSourceType.MANUAL);

        occurrence.setLinkedTaskInstanceId(linkedTaskInstanceId);
        occurrence.setLinkedTaskTemplateId(linkedTaskTemplateId);

        return occurrence;
    }

    /**
     * Create a schedule occurrence from a ScheduleTemplate.
     *
     * Template:
     * "Deep Work every weekday 9:00 - 11:00"
     *
     * Occurrence:
     * "Deep Work on 2026-05-08 9:00 - 11:00"
     */
    public ScheduleOccurrence createFromTemplate(
            ScheduleTemplate template,
            LocalDate occurrenceDate,
            LocalDate scheduledDate,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            LocalDateTime userNowLocal
    ) {
        if (template == null) {
            throw new IllegalArgumentException("ScheduleTemplate is required");
        }

        if (occurrenceDate == null) {
            throw new IllegalArgumentException("occurrenceDate is required");
        }

        LocalDate safeScheduledDate = scheduledDate == null
                ? occurrenceDate
                : scheduledDate;

        validateTitle(template.getTitle());
        validateTimeWindow(startDateTime, endDateTime);

        ScheduleOccurrence occurrence = new ScheduleOccurrence();

        occurrence.setUserId(template.getUserId());
        occurrence.setTemplateId(template.getId());

        occurrence.setTitleSnapshot(template.getTitle().trim());
        occurrence.setTypeSnapshot(
                template.getType() == null
                        ? ScheduleBlockType.OTHER
                        : template.getType()
        );
        occurrence.setDescriptionSnapshot(normalize(template.getDescription()));

        occurrence.setOccurrenceDate(occurrenceDate);
        occurrence.setScheduledDate(safeScheduledDate);

        occurrence.setStartDateTime(startDateTime);
        occurrence.setEndDateTime(endDateTime);

        occurrence.setStatus(resolveInitialStatus(startDateTime, endDateTime, userNowLocal));
        occurrence.setPreviousStatus(null);

        occurrence.setSourceType(ScheduleSourceType.RECURRING_SPAWN);

        return occurrence;
    }

    /**
     * Create a new target occurrence after rescheduling an existing occurrence.
     *
     * Old occurrence:
     * - becomes RESCHEDULED
     *
     * New occurrence:
     * - becomes PLANNED / ACTIVE / EXPIRED depending on current time
     * - sourceType = RESCHEDULED
     *
     * Important:
     * We detach templateId to avoid unique(template_id, occurrence_date) conflicts.
     */
    public ScheduleOccurrence createRescheduledTarget(
            ScheduleOccurrence source,
            LocalDateTime targetStartDateTime,
            LocalDateTime targetEndDateTime,
            LocalDateTime userNowLocal
    ) {
        if (source == null) {
            throw new IllegalArgumentException("source occurrence is required");
        }

        validateTimeWindow(targetStartDateTime, targetEndDateTime);

        ScheduleOccurrence target = new ScheduleOccurrence();

        target.setUserId(source.getUserId());

        /**
         * Important:
         * Rescheduled target is detached from templateId to avoid conflict with
         * unique(template_id, occurrence_date).
         */
        target.setTemplateId(null);

        target.setTitleSnapshot(source.getTitleSnapshot());
        target.setTypeSnapshot(
                source.getTypeSnapshot() == null
                        ? ScheduleBlockType.OTHER
                        : source.getTypeSnapshot()
        );
        target.setDescriptionSnapshot(source.getDescriptionSnapshot());

        target.setOccurrenceDate(targetStartDateTime.toLocalDate());
        target.setScheduledDate(targetStartDateTime.toLocalDate());

        target.setStartDateTime(targetStartDateTime);
        target.setEndDateTime(targetEndDateTime);

        target.setStatus(resolveInitialStatus(targetStartDateTime, targetEndDateTime, userNowLocal));
        target.setPreviousStatus(null);

        target.setSourceType(ScheduleSourceType.RESCHEDULED);

        target.setLinkedTaskInstanceId(source.getLinkedTaskInstanceId());
        target.setLinkedTaskTemplateId(source.getLinkedTaskTemplateId());

        target.setRescheduledFromOccurrenceId(source.getId());

        return target;
    }

    /**
     * Create a rescheduled occurrence from a template exception before original occurrence exists.
     *
     * Example:
     * Template repeats every Monday 9-11.
     * User moves next Monday's block to Tuesday 14-16 before spawner creates it.
     */
    public ScheduleOccurrence createRescheduledFromTemplateException(
            ScheduleTemplate template,
            LocalDate originalOccurrenceDate,
            LocalDateTime targetStartDateTime,
            LocalDateTime targetEndDateTime,
            LocalDateTime userNowLocal
    ) {
        if (template == null) {
            throw new IllegalArgumentException("ScheduleTemplate is required");
        }

        if (originalOccurrenceDate == null) {
            throw new IllegalArgumentException("originalOccurrenceDate is required");
        }

        validateTimeWindow(targetStartDateTime, targetEndDateTime);

        ScheduleOccurrence occurrence = new ScheduleOccurrence();

        occurrence.setUserId(template.getUserId());

        /**
         * Detached for safety against unique(template_id, occurrence_date).
         */
        occurrence.setTemplateId(null);

        occurrence.setTitleSnapshot(template.getTitle());
        occurrence.setTypeSnapshot(
                template.getType() == null
                        ? ScheduleBlockType.OTHER
                        : template.getType()
        );
        occurrence.setDescriptionSnapshot(template.getDescription());

        occurrence.setOccurrenceDate(originalOccurrenceDate);
        occurrence.setScheduledDate(targetStartDateTime.toLocalDate());

        occurrence.setStartDateTime(targetStartDateTime);
        occurrence.setEndDateTime(targetEndDateTime);

        occurrence.setStatus(resolveInitialStatus(targetStartDateTime, targetEndDateTime, userNowLocal));
        occurrence.setPreviousStatus(null);

        occurrence.setSourceType(ScheduleSourceType.RESCHEDULED);

        return occurrence;
    }

    public ScheduleOccurrenceStatus resolveInitialStatus(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            LocalDateTime userNowLocal
    ) {
        if (startDateTime == null || endDateTime == null) {
            return ScheduleOccurrenceStatus.PLANNED;
        }

        if (userNowLocal == null) {
            return ScheduleOccurrenceStatus.PLANNED;
        }

        if (!userNowLocal.isBefore(startDateTime) && userNowLocal.isBefore(endDateTime)) {
            return ScheduleOccurrenceStatus.ACTIVE;
        }

        if (!userNowLocal.isBefore(endDateTime)) {
            return ScheduleOccurrenceStatus.EXPIRED;
        }

        return ScheduleOccurrenceStatus.PLANNED;
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateTitle(String title) {
        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException("title is required");
        }
    }

    private void validateTimeWindow(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        if (startDateTime == null || endDateTime == null) {
            throw new IllegalArgumentException("startDateTime and endDateTime are required");
        }

        if (!startDateTime.isBefore(endDateTime)) {
            throw new IllegalArgumentException("startDateTime must be before endDateTime");
        }
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }
}