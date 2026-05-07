package com.lifeos.backend.financial.infrastructure.provider.payway.log;

import com.lifeos.backend.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/financial-provider/payway/callback-logs")
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "lifeos.payway", name = "enabled", havingValue = "true")
public class PayWayCallbackLogController {

    private final PayWayCallbackLogRepository repository;

    @GetMapping("/user/{userId}")
    public ApiResponse<List<PayWayCallbackLog>> getByUser(@PathVariable UUID userId) {
        return ApiResponse.success(repository.findByUserIdOrderByCreatedAtDesc(userId));
    }
}