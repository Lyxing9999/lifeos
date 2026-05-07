package com.lifeos.backend.schedule.application;

import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.api.response.ScheduleCountSummaryResponse;
import com.lifeos.backend.schedule.api.response.ScheduleSurfaceBffResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScheduleBffService {

    private final ScheduleQueryService queryService;

    public ScheduleSurfaceBffResponse getSurfaces(UUID userId, LocalDate today) {
        // Fetch all distinct surfaces based on today's reality
        List<ScheduleBlockResponse> activeBlocks = queryService.getActiveBlocks(userId, today);
        List<ScheduleBlockResponse> inactiveBlocks = queryService.getInactiveBlocks(userId, today);
        List<ScheduleBlockResponse> historyBlocks = queryService.getHistoryBlocks(userId, today);

        ScheduleCountSummaryResponse counts = ScheduleCountSummaryResponse.builder()
                .total(activeBlocks.size() + inactiveBlocks.size() + historyBlocks.size())
                .active(activeBlocks.size())
                .inactive(inactiveBlocks.size())
                .history(historyBlocks.size()) // Add this to your DTO if it's missing!
                .build();

        return ScheduleSurfaceBffResponse.builder()
                .date(today)
                .activeBlocks(activeBlocks)
                .inactiveBlocks(inactiveBlocks)
                .historyBlocks(historyBlocks) // Now Flutter has exactly what it needs for the History tab
                .counts(counts)
                .build();
    }
}