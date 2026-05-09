//package com.lifeos.backend.financial.infrastructure.provider.openbanking;
//
//import com.lifeos.backend.financial.application.FinancialIngestionService;
//import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderContext;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//import java.util.List;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//public class OpenBankingSyncService {
//
//    private final OpenBankingAdapter adapter;
//    private final FinancialIngestionService ingestionService;
//
//    public int sync(UUID userId, String timezone, String consentId, List<OpenBankingTransactionRow> rows) {
//        int count = 0;
//
//        FinancialProviderContext context = new FinancialProviderContext(userId, timezone, consentId);
//
//        for (OpenBankingTransactionRow row : rows) {
//            ingestionService.ingest(adapter.map(row, context));
//            count++;
//        }
//
//        return count;
//    }
//}