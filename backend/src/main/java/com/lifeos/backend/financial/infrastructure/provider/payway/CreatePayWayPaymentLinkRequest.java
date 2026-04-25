package com.lifeos.backend.financial.infrastructure.provider.payway;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreatePayWayPaymentLinkRequest {
    @NotBlank
    private String title;
    @NotBlank
    private String amount;
    @NotBlank
    private String currency;

    private String description;
    private String paymentLimit;
    private String expiredDate;
    private String merchantRefNo;
}