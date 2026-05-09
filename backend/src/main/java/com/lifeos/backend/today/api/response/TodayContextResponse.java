package com.lifeos.backend.today.api.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
public class TodayContextResponse {

    private LocalDate date;
    private LocalDate userToday;
    private LocalDateTime userNowLocal;
    private String timezone;

    private Boolean viewingToday;
    private Boolean viewingPast;
    private Boolean viewingFuture;

    private String dayPhase;
}