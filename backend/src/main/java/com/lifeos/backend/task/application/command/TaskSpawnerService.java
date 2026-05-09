package com.lifeos.backend.task.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.application.factory.RecurringTaskSpawnFactory;
import com.lifeos.backend.task.application.factory.RecurringTaskSpawnFactory.SpawnPlan;
import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.repository.MutationHistoryRepository;
import com.lifeos.backend.task.domain.repository.TaskInstanceRepository;
import com.lifeos.backend.task.domain.repository.TaskOccurrenceExceptionRepository;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Application service for SPAWN.
 *
 * Responsibility:
 * - find active TaskTemplate spawn candidates
 * - check existing TaskInstance records
 * - respect SKIPPED / RESCHEDULED TaskOccurrenceException records
 * - create TaskInstance rows through RecurringTaskSpawnFactory
 * - record MutationHistory
 *
 * Important:
 * This service owns persistence.
 * RecurringTaskSpawnFactory only builds objects and spawn plans.
 */
@Service
@RequiredArgsConstructor
public class TaskSpawnerService {

    private static final int DEFAULT_PAST_WINDOW_DAYS = 1;
    private static final int DEFAULT_FUTURE_WINDOW_DAYS = 7;

    private final TaskTemplateRepository taskTemplateRepository;
    private final TaskInstanceRepository taskInstanceRepository;
    private final TaskOccurrenceExceptionRepository occurrenceExceptionRepository;
    private final MutationHistoryRepository mutationHistoryRepository;
    private final RecurringTaskSpawnFactory recurringTaskSpawnFactory;
    private final UserTimeService userTimeService;

    /**
     * Spawn missing task instances for the default window:
     *
     * today - 1 day -> today + 7 days
     *
     * Good for dogfooding because the app can show today and upcoming tasks.
     */
    @Transactional
    public TaskSpawnResult spawnDefaultWindow(UUID userId) {
        LocalDate userToday = resolveUserToday(userId);

        return spawnWindow(
                userId,
                userToday.minusDays(DEFAULT_PAST_WINDOW_DAYS),
                userToday.plusDays(DEFAULT_FUTURE_WINDOW_DAYS),
                SpawnActor.SYSTEM
        );
    }

    /**
     * Spawn missing instances for a custom window.
     *
     * Useful for:
     * - engine jobs
     * - manual repair
     * - testing
     */
    @Transactional
    public TaskSpawnResult spawnWindow(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        return spawnWindow(userId, windowStart, windowEnd, SpawnActor.SYSTEM);
    }

    /**
     * Spawn missing instances for one template.
     *
     * Useful after:
     * - creating a new recurring template
     * - changing recurrence rule
     * - repairing one template
     */
    @Transactional
    public TaskSpawnResult spawnTemplateWindow(
            UUID userId,
            UUID templateId,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        validateUserId(userId);
        validateWindow(windowStart, windowEnd);

        LocalDate userToday = resolveUserToday(userId);

        TaskTemplate template = taskTemplateRepository.findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Task template not found"));

        SingleTemplateSpawnResult result = spawnForTemplate(
                template,
                windowStart,
                windowEnd,
                userToday,
                SpawnActor.SYSTEM
        );

        return TaskSpawnResult.singleTemplate(
                userId,
                windowStart,
                windowEnd,
                result
        );
    }

    private TaskSpawnResult spawnWindow(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd,
            SpawnActor actor
    ) {
        validateUserId(userId);
        validateWindow(windowStart, windowEnd);

        LocalDate userToday = resolveUserToday(userId);

        List<TaskTemplate> templates = taskTemplateRepository.findSpawnCandidates(
                userId,
                windowStart,
                windowEnd
        );

        int templatesScanned = 0;
        int instancesCreated = 0;
        int skippedByException = 0;
        int ignoredExisting = 0;
        int noOccurrenceInWindow = 0;

        List<UUID> createdInstanceIds = new ArrayList<>();

        for (TaskTemplate template : templates) {
            templatesScanned++;

            SingleTemplateSpawnResult result = spawnForTemplate(
                    template,
                    windowStart,
                    windowEnd,
                    userToday,
                    actor
            );

            instancesCreated += result.instancesCreated();
            skippedByException += result.skippedByException();
            ignoredExisting += result.ignoredExisting();
            noOccurrenceInWindow += result.noOccurrenceInWindow();

            createdInstanceIds.addAll(result.createdInstanceIds());
        }

        return new TaskSpawnResult(
                userId,
                windowStart,
                windowEnd,
                templatesScanned,
                instancesCreated,
                skippedByException,
                ignoredExisting,
                noOccurrenceInWindow,
                createdInstanceIds
        );
    }

    private SingleTemplateSpawnResult spawnForTemplate(
            TaskTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd,
            LocalDate userToday,
            SpawnActor actor
    ) {
        if (template == null || !template.isActiveTemplate() || !template.isRecurring()) {
            return SingleTemplateSpawnResult.empty();
        }

        List<LocalDate> occurrenceDates = recurringTaskSpawnFactory.getOccurrenceDates(
                template,
                windowStart,
                windowEnd
        );

        if (occurrenceDates.isEmpty()) {
            return SingleTemplateSpawnResult.emptyNoOccurrence();
        }

        Set<LocalDate> existingOccurrenceDates = findExistingOccurrenceDates(
                template.getId(),
                occurrenceDates
        );

        List<TaskOccurrenceException> exceptions =
                occurrenceExceptionRepository.findByTemplateIdAndOccurrenceDateBetween(
                        template.getId(),
                        windowStart,
                        windowEnd
                );

        SpawnPlan plan = recurringTaskSpawnFactory.buildSpawnPlan(
                template,
                windowStart,
                windowEnd,
                userToday,
                existingOccurrenceDates,
                exceptions
        );

        if (!plan.hasInstancesToCreate()) {
            return new SingleTemplateSpawnResult(
                    0,
                    plan.skippedDates().size(),
                    plan.ignoredExistingDates().size(),
                    0,
                    List.of()
            );
        }

        /**
         * Defensive re-check before save.
         *
         * The factory already checked existing dates, but this prevents most
         * duplicate creation if spawnWindow is called twice in the same flow.
         *
         * Database unique constraint still remains the final protection.
         */
        List<TaskInstance> safeInstancesToCreate = plan.instancesToCreate()
                .stream()
                .filter(instance -> !alreadyExists(instance))
                .toList();

        if (safeInstancesToCreate.isEmpty()) {
            return new SingleTemplateSpawnResult(
                    0,
                    plan.skippedDates().size(),
                    plan.ignoredExistingDates().size() + plan.instancesToCreate().size(),
                    0,
                    List.of()
            );
        }

        List<TaskInstance> savedInstances = taskInstanceRepository.saveAll(safeInstancesToCreate);

        List<MutationHistory> histories = savedInstances.stream()
                .map(instance -> toSpawnMutation(instance, actor))
                .toList();

        mutationHistoryRepository.saveAll(histories);

        List<UUID> createdIds = savedInstances.stream()
                .map(TaskInstance::getId)
                .toList();

        return new SingleTemplateSpawnResult(
                savedInstances.size(),
                plan.skippedDates().size(),
                plan.ignoredExistingDates().size(),
                0,
                createdIds
        );
    }

    private MutationHistory toSpawnMutation(
            TaskInstance instance,
            SpawnActor actor
    ) {
        MutationType mutationType = actor == SpawnActor.SYSTEM
                ? MutationType.SYSTEM_AUTO_SPAWNED
                : MutationType.INSTANCE_SPAWNED;

        return MutationHistory.lifecycle(
                instance.getUserId(),
                instance.getTemplateId(),
                instance.getId(),
                mutationType,
                TaskTransitionType.SPAWN,
                null,
                instance.getStatus(),
                actor.name(),
                "Task instance spawned from template"
        );
    }

    private Set<LocalDate> findExistingOccurrenceDates(
            UUID templateId,
            List<LocalDate> occurrenceDates
    ) {
        if (templateId == null || occurrenceDates == null || occurrenceDates.isEmpty()) {
            return Set.of();
        }

        Set<LocalDate> existing = new HashSet<>();

        for (LocalDate occurrenceDate : occurrenceDates) {
            boolean exists = taskInstanceRepository.existsByTemplateIdAndOccurrenceDate(
                    templateId,
                    occurrenceDate
            );

            if (exists) {
                existing.add(occurrenceDate);
            }
        }

        return existing;
    }

    private boolean alreadyExists(TaskInstance instance) {
        if (instance == null) {
            return true;
        }

        if (instance.getTemplateId() == null || instance.getOccurrenceDate() == null) {
            return false;
        }

        return taskInstanceRepository.existsByTemplateIdAndOccurrenceDate(
                instance.getTemplateId(),
                instance.getOccurrenceDate()
        );
    }

    private LocalDate resolveUserToday(UUID userId) {
        ZoneId zoneId = userTimeService.getUserZoneId(userId);
        return Instant.now().atZone(zoneId).toLocalDate();
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateWindow(LocalDate windowStart, LocalDate windowEnd) {
        if (windowStart == null) {
            throw new IllegalArgumentException("windowStart is required");
        }

        if (windowEnd == null) {
            throw new IllegalArgumentException("windowEnd is required");
        }

        if (windowEnd.isBefore(windowStart)) {
            throw new IllegalArgumentException("windowEnd must be on or after windowStart");
        }
    }

    public enum SpawnActor {
        USER,
        SYSTEM,
        ENGINE
    }

    private record SingleTemplateSpawnResult(
            int instancesCreated,
            int skippedByException,
            int ignoredExisting,
            int noOccurrenceInWindow,
            List<UUID> createdInstanceIds
    ) {
        private static SingleTemplateSpawnResult empty() {
            return new SingleTemplateSpawnResult(0, 0, 0, 0, List.of());
        }


        private static SingleTemplateSpawnResult emptyNoOccurrence() {
            return new SingleTemplateSpawnResult(0, 0, 0, 1, List.of());
        }
    }

    public record TaskSpawnResult(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd,
            int templatesScanned,
            int instancesCreated,
            int skippedByException,
            int ignoredExisting,
            int noOccurrenceInWindow,
            List<UUID> createdInstanceIds
    ) {
        private static TaskSpawnResult singleTemplate(
                UUID userId,
                LocalDate windowStart,
                LocalDate windowEnd,
                SingleTemplateSpawnResult result
        ) {
            return new TaskSpawnResult(
                    userId,
                    windowStart,
                    windowEnd,
                    1,
                    result.instancesCreated(),
                    result.skippedByException(),
                    result.ignoredExisting(),
                    result.noOccurrenceInWindow(),
                    result.createdInstanceIds()
            );
        }
    }
}