package com.lifeos.backend.today.application;

import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.infrastructure.mapper.ScheduleOccurrenceMapper;
import com.lifeos.backend.today.api.response.TodayScheduleSectionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@Component
@RequiredArgsConstructor
public class TodayScheduleSectionAssembler {

    private final ScheduleOccurrenceMapper scheduleOccurrenceMapper;

    public TodayScheduleSectionResponse assemble(
            List<ScheduleOccurrence> occurrences,
            LocalDate requestedDate,
            LocalDate userToday,
            LocalDateTime userNowLocal
    ) {
        List<ScheduleOccurrence> safeOccurrences = safeList(occurrences)
                .stream()
                .sorted(scheduleComparator())
                .toList();

        boolean viewingToday = requestedDate != null && requestedDate.equals(userToday);

        List<ScheduleOccurrence> activeNow = safeOccurrences.stream()
                .filter(occurrence -> isActiveNow(occurrence, userNowLocal))
                .toList();

        List<ScheduleOccurrence> upcoming = safeOccurrences.stream()
                .filter(occurrence -> isUpcoming(occurrence, userNowLocal, viewingToday))
                .toList();

        List<ScheduleOccurrence> expired = safeOccurrences.stream()
                .filter(occurrence -> occurrence.getStatus() == ScheduleOccurrenceStatus.EXPIRED)
                .toList();

        ScheduleOccurrence current = activeNow.stream()
                .findFirst()
                .orElse(null);

        ScheduleOccurrence next = upcoming.stream()
                .findFirst()
                .orElse(null);

        return TodayScheduleSectionResponse.builder()
                .currentSchedule(map(current))
                .nextSchedule(map(next))

                .activeNow(map(activeNow))
                .upcomingToday(map(upcoming))
                .expiredToday(map(expired))
                .visibleToday(map(safeOccurrences))

                .activeNowCount(activeNow.size())
                .upcomingTodayCount(upcoming.size())
                .expiredTodayCount(expired.size())
                .visibleTodayCount(safeOccurrences.size())
                .build();
    }

    private boolean isActiveNow(
            ScheduleOccurrence occurrence,
            LocalDateTime userNowLocal
    ) {
        if (occurrence == null || userNowLocal == null) {
            return false;
        }

        if (occurrence.getStartDateTime() == null || occurrence.getEndDateTime() == null) {
            return false;
        }

        return !userNowLocal.isBefore(occurrence.getStartDateTime())
                && userNowLocal.isBefore(occurrence.getEndDateTime());
    }

    private boolean isUpcoming(
            ScheduleOccurrence occurrence,
            LocalDateTime userNowLocal,
            boolean viewingToday
    ) {
        if (occurrence == null) {
            return false;
        }

        if (occurrence.getStatus() != ScheduleOccurrenceStatus.PLANNED
                && occurrence.getStatus() != ScheduleOccurrenceStatus.ACTIVE) {
            return false;
        }

        if (!viewingToday) {
            return true;
        }

        return occurrence.getStartDateTime() != null
                && userNowLocal != null
                && occurrence.getStartDateTime().isAfter(userNowLocal);
    }

    private ScheduleOccurrenceResponse map(ScheduleOccurrence occurrence) {
        return scheduleOccurrenceMapper.toResponse(occurrence);
    }

    private List<ScheduleOccurrenceResponse> map(List<ScheduleOccurrence> occurrences) {
        return safeList(occurrences).stream()
                .map(scheduleOccurrenceMapper::toResponse)
                .toList();
    }

    private Comparator<ScheduleOccurrence> scheduleComparator() {
        return Comparator
                .comparing(ScheduleOccurrence::getStartDateTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(ScheduleOccurrence::getEndDateTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(ScheduleOccurrence::getTitleSnapshot, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private <T> List<T> safeList(List<T> list) {
        return list == null ? List.of() : list;
    }
}