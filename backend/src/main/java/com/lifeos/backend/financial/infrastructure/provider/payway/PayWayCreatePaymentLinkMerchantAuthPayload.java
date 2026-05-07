package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class PayWayCreatePaymentLinkMerchantAuthPayload {

    @JsonProperty("mc_id")
    private String mcId;

    private String title;
    private String amount;
    private String currency;
    private String description;

    @JsonProperty("payment_limit")
    private String paymentLimit;

    @JsonProperty("expired_date")
    private String expiredDate;

    @JsonProperty("return_url")
    private String returnUrl;

    @JsonProperty("merchant_ref_no")
    private String merchantRefNo;
}