package com.lifeos.backend.financial.infrastructure.provider.payway.polling;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class PayWayTransactionListResponse {

    private List<Item> data;
    private String pagination;
    private String page;
    private Status status;

    @JsonProperty("tran_id")
    private String tranId;

    @Getter
    @Setter
    public static class Item {
        @JsonProperty("transaction_id")
        private String transactionId;

        @JsonProperty("transaction_date")
        private String transactionDate;

        private String apv;

        @JsonProperty("payment_status")
        private String paymentStatus;

        @JsonProperty("payment_status_code")
        private Integer paymentStatusCode;

        @JsonProperty("original_amount")
        private BigDecimal originalAmount;

        @JsonProperty("original_currency")
        private String originalCurrency;

        @JsonProperty("total_amount")
        private BigDecimal totalAmount;

        @JsonProperty("discount_amount")
        private BigDecimal discountAmount;

        @JsonProperty("refund_amount")
        private BigDecimal refundAmount;

        @JsonProperty("payment_amount")
        private BigDecimal paymentAmount;

        @JsonProperty("payment_currency")
        private String paymentCurrency;

        @JsonProperty("first_name")
        private String firstName;

        @JsonProperty("last_name")
        private String lastName;

        private String email;
        private String phone;

        @JsonProperty("bank_ref")
        private String bankRef;

        @JsonProperty("payment_type")
        private String paymentType;

        @JsonProperty("payer_account")
        private String payerAccount;

        @JsonProperty("bank_name")
        private String bankName;

        @JsonProperty("card_source")
        private String cardSource;
    }

    @Getter
    @Setter
    public static class Status {
        private String code;
        private String message;

        @JsonProperty("tran_id")
        private String tranId;
    }
}