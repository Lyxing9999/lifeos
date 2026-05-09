//package com.lifeos.backend.financial.infrastructure.provider.csv;
//
//import com.lifeos.backend.financial.application.FinancialIngestionService;
//import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderContext;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//import org.springframework.web.multipart.MultipartFile;
//
//import java.io.BufferedReader;
//import java.io.InputStreamReader;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//public class CsvFinancialImportService {
//
//    private final CsvFinancialAdapter adapter;
//    private final FinancialIngestionService ingestionService;
//
//    public int importFile(UUID userId, String timezone, MultipartFile file) {
//        int count = 0;
//
//        try (BufferedReader reader = new BufferedReader(new InputStreamReader(file.getInputStream()))) {
//            reader.readLine(); // header
//
//            String line;
//            while ((line = reader.readLine()) != null) {
//                String[] p = line.split(",");
//
//                CsvFinancialRow row = new CsvFinancialRow();
//                row.setPaidAt(p[0]);
//                row.setAmount(p[1]);
//                row.setCurrency(p[2]);
//                row.setMerchantName(p[3]);
//                row.setDescription(p.length > 4 ? p[4] : null);
//
//                ingestionService.ingest(
//                        adapter.map(row, new FinancialProviderContext(userId, timezone, "csv-import"))
//                );
//                count++;
//            }
//
//            return count;
//        } catch (Exception e) {
//            throw new IllegalStateException("Failed to import CSV financial events", e);
//        }
//    }
//}