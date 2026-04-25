package com.lifeos.backend.financial.infrastructure.provider.openbanking;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Getter
@Setter
public class OpenBankingTransactionRow {
    private String providerTransactionId;
    private BigDecimal amount;
    private String currency;
    private String merchantName;
    private String description;
    private Instant bookedAt;
    private String accountMasked;
    private String rawReference;
    private String countryCode;
}