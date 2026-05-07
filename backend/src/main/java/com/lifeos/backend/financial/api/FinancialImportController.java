package com.lifeos.backend.financial.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.financial.infrastructure.provider.csv.CsvFinancialImportService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/financial-import")
@RequiredArgsConstructor
public class FinancialImportController {

    private final CsvFinancialImportService csvFinancialImportService;

    @PostMapping("/csv/{userId}")
    public ApiResponse<String> importCsv(
            @PathVariable UUID userId,
            @RequestParam("file") MultipartFile file,
            @RequestParam String timezone
    ) {
        int count = csvFinancialImportService.importFile(userId, timezone, file);
        return ApiResponse.success("Imported " + count + " financial rows");
    }
}