package com.lifeos.backend.notification.application;

import com.lifeos.backend.notification.domain.ReminderDecision;
import com.lifeos.backend.notification.domain.ReminderSignal;
import com.lifeos.backend.notification.domain.ReminderType;
import org.springframework.stereotype.Service;

@Service
public class ReminderRuleService {

    public ReminderDecision evaluate(ReminderSignal signal) {
        if (signal.isSummaryReady()) {
            return ReminderDecision.builder()
                    .shouldSend(true)
                    .reminderType(ReminderType.DAILY_SUMMARY_READY)
                    .title("Daily summary ready")
                    .body("Your LifeOS daily summary is ready to review.")
                    .build();
        }

        if (signal.getOverdueTaskCount() != null && signal.getOverdueTaskCount() > 0) {
            return ReminderDecision.builder()
                    .shouldSend(true)
                    .reminderType(ReminderType.TASK_OVERDUE)
                    .title("Overdue tasks detected")
                    .body("You have tasks that need attention today.")
                    .build();
        }

        if (signal.getActiveTaskCount() != null && signal.getActiveTaskCount() > 0) {
            return ReminderDecision.builder()
                    .shouldSend(true)
                    .reminderType(ReminderType.TASK_DUE)
                    .title("Tasks ready to work on")
                    .body("You have active tasks scheduled for today.")
                    .build();
        }

        return ReminderDecision.builder()
                .shouldSend(false)
                .reminderType(null)
                .title(null)
                .body(null)
                .build();
    }
}