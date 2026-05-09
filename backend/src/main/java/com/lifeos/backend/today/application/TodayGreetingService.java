package com.lifeos.backend.today.application;

import com.lifeos.backend.today.api.response.TodayCountsResponse;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class TodayGreetingService {

    public String generate(
            String userName,
            LocalDateTime userNowLocal,
            TodayCountsResponse counts
    ) {
        String firstName = firstName(userName);
        int hour = userNowLocal == null ? 9 : userNowLocal.getHour();

        int overdue = counts == null || counts.getOverdueTasks() == null
                ? 0
                : counts.getOverdueTasks();

        int open = counts == null || counts.getOpenTasks() == null
                ? 0
                : counts.getOpenTasks();

        if (hour >= 5 && hour < 12) {
            if (overdue > 0) {
                return "Good morning, " + firstName + ". Start by clearing the overdue item.";
            }

            if (open > 0) {
                return "Good morning, " + firstName + ". Choose one strong focus and move.";
            }

            return "Good morning, " + firstName + ". Your day is clear.";
        }

        if (hour >= 12 && hour < 17) {
            if (open > 0) {
                return "Keep the momentum going, " + firstName + ".";
            }

            return "Good afternoon, " + firstName + ". You are clear for now.";
        }

        if (hour >= 17 && hour < 22) {
            if (open > 0) {
                return "Evening, " + firstName + ". Wrap up the important things first.";
            }

            return "Excellent work today, " + firstName + ".";
        }

        return "Late night, " + firstName + ". Keep it light and prepare tomorrow.";
    }

    private String firstName(String userName) {
        if (userName == null || userName.isBlank()) {
            return "Commander";
        }

        return userName.trim().split("\\s+")[0];
    }
}