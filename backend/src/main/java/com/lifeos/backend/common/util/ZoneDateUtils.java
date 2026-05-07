package com.lifeos.backend.common.util;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;

public final class ZoneDateUtils {

    private ZoneDateUtils() {
    }

    public static ZoneId parseZoneId(String timezone) {
        try {
            return ZoneId.of(timezone);
        } catch (Exception ex) {
            throw new IllegalArgumentException("Invalid timezone: " + timezone);
        }
    }

    public static Instant startOfDayUtc(LocalDate date, ZoneId zoneId) {
        return date.atStartOfDay(zoneId).toInstant();
    }

    public static Instant endOfDayUtc(LocalDate date, ZoneId zoneId) {
        return date.plusDays(1).atStartOfDay(zoneId).minusNanos(1).toInstant();
    }

    public static LocalDate toUserLocalDate(Instant instant, ZoneId zoneId) {
        return instant.atZone(zoneId).toLocalDate();
    }

    public static ZonedDateTime toUserZonedDateTime(Instant instant, ZoneId zoneId) {
        return instant.atZone(zoneId);
    }
}