package com.lifeos.backend.financial.infrastructure.provider.payway.polling;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class PayWayTransactionListRequest {

    @JsonProperty("req_time")
    private String reqTime;

    @JsonProperty("merchant_id")
    private String merchantId;

    @JsonProperty("from_date")
    private String fromDate;

    @JsonProperty("to_date")
    private String toDate;

    @JsonProperty("from_amount")
    private String fromAmount;

    @JsonProperty("to_amount")
    private String toAmount;

    private String status;
    private String page;
    private String pagination;
    private String hash;
}