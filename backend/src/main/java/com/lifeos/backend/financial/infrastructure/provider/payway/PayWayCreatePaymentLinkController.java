package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.lifeos.backend.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/financial-provider/payway")
@RequiredArgsConstructor
@Tag(name = "PayWay Create Link", description = "Create PayWay payment link APIs")
@ConditionalOnProperty(prefix = "lifeos.payway", name = "enabled", havingValue = "true")
public class PayWayCreatePaymentLinkController {

    private final PayWayCreatePaymentLinkService createPaymentLinkService;

    @PostMapping("/payment-link/create/{userId}")
    public ApiResponse<PayWayCreatePaymentLinkResponse> create(
            @PathVariable String userId,
            @Valid @RequestBody CreatePayWayPaymentLinkRequest request
    ) {
        return ApiResponse.success(
                createPaymentLinkService.create(request, userId),
                "PayWay payment link created"
        );
    }
}