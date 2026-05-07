package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PayWayCreatePaymentLinkResponse {

    private Data data;
    private Status status;

    @JsonProperty("tran_id")
    private String tranId;

    @Getter
    @Setter
    public static class Data {
        private String id;
        private String title;
        private String amount;
        private String currency;
        private String status;
        private String description;

        @JsonProperty("payment_limit")
        private Integer paymentLimit;

        @JsonProperty("expired_date")
        private Long expiredDate;

        @JsonProperty("return_url")
        private String returnUrl;

        @JsonProperty("merchant_ref_no")
        private String merchantRefNo;

        @JsonProperty("payment_link")
        private String paymentLink;

        @JsonProperty("outlet_name")
        private String outletName;
    }

    @Getter
    @Setter
    public static class Status {
        private String code;
        private String message;
    }
}