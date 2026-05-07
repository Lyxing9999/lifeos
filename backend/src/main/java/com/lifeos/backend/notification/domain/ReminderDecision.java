package com.lifeos.backend.notification.domain;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ReminderDecision {
    private boolean shouldSend;
    private ReminderType reminderType;
    private String title;
    private String body;
}