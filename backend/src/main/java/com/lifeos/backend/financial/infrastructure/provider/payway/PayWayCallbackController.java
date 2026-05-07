package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.lifeos.backend.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/financial-provider/payway")
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "lifeos.payway", name = "enabled", havingValue = "true")
@Slf4j
public class PayWayCallbackController {

    private final PayWayCallbackService callbackService;

    @PostMapping("/callback/{userId}")
    public ApiResponse<Void> callback(@PathVariable UUID userId, @RequestBody PayWayCallbackPayload payload) {
        log.info("payway_callback_http_received userId={} tranId={} status={} merchantRefNo={}",
                userId, payload.getTranId(), payload.getStatus(), payload.getMerchantRefNo());

        callbackService.handle(userId, "Asia/Phnom_Penh", "payway-callback-" + userId, payload);

        return ApiResponse.success(null, "PayWay callback processed");
    }
}