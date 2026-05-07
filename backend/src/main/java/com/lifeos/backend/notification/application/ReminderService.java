package com.lifeos.backend.notification.application;

import com.lifeos.backend.notification.domain.ReminderDecision;
import com.lifeos.backend.notification.domain.ReminderSignal;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReminderService {

    private final ReminderRuleService reminderRuleService;

    public ReminderDecision buildDecision(ReminderSignal signal) {
        ReminderDecision decision = reminderRuleService.evaluate(signal);

        log.info("reminder_decision_built userId={} date={} shouldSend={} type={}",
                signal.getUserId(),
                signal.getDate(),
                decision.isShouldSend(),
                decision.getReminderType());

        return decision;
    }
}