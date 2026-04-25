package com.lifeos.backend.financial.infrastructure.provider.csv;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CsvFinancialRow {
    private String paidAt;
    private String amount;
    private String currency;
    private String merchantName;
    private String description;
}