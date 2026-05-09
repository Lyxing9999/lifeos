package com.lifeos.backend.timeline.domain.service;

import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Comparator;
import java.util.List;

@Component
public class TimelineSortService {

    public List<TimelineEntry> sortChronologically(List<TimelineEntry> entries) {
        if (entries == null || entries.isEmpty()) {
            return List.of();
        }

        return entries.stream()
                .sorted(entryComparator())
                .toList();
    }

    public Comparator<TimelineEntry> entryComparator() {
        return Comparator
                .comparing(this::sortInstant, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(this::sortOrder, Comparator.nullsLast(Integer::compareTo))
                .thenComparing(TimelineEntry::getTitleSnapshot, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private Instant sortInstant(TimelineEntry entry) {
        if (entry == null) {
            return null;
        }

        return entry.getStartAt();
    }

    private Integer sortOrder(TimelineEntry entry) {
        if (entry == null) {
            return null;
        }

        return entry.getSortOrder();
    }
}