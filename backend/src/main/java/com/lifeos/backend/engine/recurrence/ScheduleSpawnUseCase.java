package com.lifeos.backend.engine.recurrence;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Port used by ScheduleSpawnerEngine.
 *
 * Later, your schedule module should implement this.
 *
 * Example:
 * @Service
 * public class ScheduleSpawnerService implements ScheduleSpawnUseCase { ... }
 */
public interface ScheduleSpawnUseCase {

    ScheduleSpawnResult spawnDefaultWindow(UUID userId);

    ScheduleSpawnResult spawnWindow(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd
    );

    record ScheduleSpawnResult(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd,
            int templatesScanned,
            int occurrencesCreated,
            int skippedByException,
            int ignoredExisting,
            List<UUID> createdOccurrenceIds
    ) {
        public static ScheduleSpawnResult empty(
                UUID userId,
                LocalDate windowStart,
                LocalDate windowEnd
        ) {
            return new ScheduleSpawnResult(
                    userId,
                    windowStart,
                    windowEnd,
                    0,
                    0,
                    0,
                    0,
                    List.of()
            );
        }
    }
}