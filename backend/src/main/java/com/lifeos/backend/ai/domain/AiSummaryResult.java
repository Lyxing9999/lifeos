package com.lifeos.backend.ai.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AiSummaryResult {
    private String summaryText;
    private String scoreExplanation;
    private String insight;
    private boolean fallbackUsed;
    private String model;
}