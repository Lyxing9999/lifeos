package com.lifeos.backend.schedule.application.policy;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * Policy for deciding schedule occurrence time-state:
 * - PLANNED -> ACTIVE
 * - PLANNED/ACTIVE -> EXPIRED
 *
 * This does not mutate.
 * ScheduleOccurrenceLifecycleService performs mutation later.
 */
@Component
public class ScheduleExpirationPolicy {

    public TimeStateDecision evaluate(
            ScheduleOccurrence occurrence,
            LocalDateTime userNowLocal
    ) {
        if (occurrence == null) {
            return TimeStateDecision.noAction("ScheduleOccurrence is required");
        }

        if (userNowLocal == null) {
            return TimeStateDecision.noAction("userNowLocal is required");
        }

        if (occurrence.getStatus() == null) {
            return TimeStateDecision.noAction("ScheduleOccurrence status is required");
        }

        if (occurrence.getStatus().isFinalState()) {
            return TimeStateDecision.noAction(
                    "Final schedule occurrence does not need time-state update"
            );
        }

        if (shouldExpire(occurrence, userNowLocal)) {
            return TimeStateDecision.expire("Schedule occurrence time window ended");
        }

        if (shouldActivate(occurrence, userNowLocal)) {
            return TimeStateDecision.activate("Schedule occurrence is active now");
        }

        return TimeStateDecision.noAction("No schedule time-state update needed");
    }

    public boolean shouldActivate(
            ScheduleOccurrence occurrence,
            LocalDateTime userNowLocal
    ) {
        if (occurrence == null || userNowLocal == null) {
            return false;
        }

        if (occurrence.getStatus() != ScheduleOccurrenceStatus.PLANNED) {
            return false;
        }

        if (occurrence.getStartDateTime() == null || occurrence.getEndDateTime() == null) {
            return false;
        }

        return !userNowLocal.isBefore(occurrence.getStartDateTime())
                && userNowLocal.isBefore(occurrence.getEndDateTime());
    }

    public boolean shouldExpire(
            ScheduleOccurrence occurrence,
            LocalDateTime userNowLocal
    ) {
        if (occurrence == null || userNowLocal == null) {
            return false;
        }

        if (!occurrence.getStatus().canExpire()) {
            return false;
        }

        if (occurrence.getEndDateTime() == null) {
            return false;
        }

        return !userNowLocal.isBefore(occurrence.getEndDateTime());
    }

    public boolean isFuture(
            ScheduleOccurrence occurrence,
            LocalDateTime userNowLocal
    ) {
        if (occurrence == null || userNowLocal == null) {
            return false;
        }

        if (occurrence.getStartDateTime() == null) {
            return false;
        }

        return occurrence.getStartDateTime().isAfter(userNowLocal);
    }

    public boolean isCurrent(
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

    public boolean isPast(
            ScheduleOccurrence occurrence,
            LocalDateTime userNowLocal
    ) {
        if (occurrence == null || userNowLocal == null) {
            return false;
        }

        if (occurrence.getEndDateTime() == null) {
            return false;
        }

        return !userNowLocal.isBefore(occurrence.getEndDateTime());
    }

    public record TimeStateDecision(
            TimeStateAction action,
            String reason
    ) {
        public static TimeStateDecision activate(String reason) {
            return new TimeStateDecision(TimeStateAction.ACTIVATE, reason);
        }

        public static TimeStateDecision expire(String reason) {
            return new TimeStateDecision(TimeStateAction.EXPIRE, reason);
        }

        public static TimeStateDecision noAction(String reason) {
            return new TimeStateDecision(TimeStateAction.NONE, reason);
        }

        public boolean shouldActivate() {
            return action == TimeStateAction.ACTIVATE;
        }

        public boolean shouldExpire() {
            return action == TimeStateAction.EXPIRE;
        }
    }

    public enum TimeStateAction {
        NONE,
        ACTIVATE,
        EXPIRE
    }
}