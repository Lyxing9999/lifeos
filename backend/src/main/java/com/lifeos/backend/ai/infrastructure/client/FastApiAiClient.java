package com.lifeos.backend.ai.infrastructure.client;

import com.lifeos.backend.ai.domain.AiSummaryRequest;
import com.lifeos.backend.ai.domain.AiSummaryResult;

public interface FastApiAiClient {
    AiSummaryResult generateSummary(AiSummaryRequest request);
}