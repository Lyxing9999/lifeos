package com.lifeos.backend.schedule.infrastructure.job;

import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleBlockRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduleArchivalJob {

    private final ScheduleBlockRepository repository;

    @Scheduled(cron = "0 0 2 * * ?")
    @Transactional
    public void autoArchiveExpiredSchedules() {
        log.info("Starting automated schedule archival job...");

        LocalDate cutoffDate = LocalDate.now().minusDays(30);

        // Fetch blocks that are NOT archived yet, but have an end date
        List<ScheduleBlock> activeBlocks = repository.findAll().stream()
                .filter(b -> !b.isArchived() && b.getRecurrenceEndDate() != null)
                .toList();

        int archiveCount = 0;
        for (ScheduleBlock block : activeBlocks) {
            if (block.getRecurrenceEndDate().isBefore(cutoffDate)) {
                block.setArchived(true);
                archiveCount++;
            }
        }

        if (archiveCount > 0) {
            repository.saveAll(activeBlocks);
        }
        log.info("Archival job complete. Automatically archived {} expired schedules.", archiveCount);
    }
}