//package com.lifeos.backend.financial.infrastructure.provider.payway.polling;
//
//import com.lifeos.backend.common.response.ApiResponse;
//import com.lifeos.backend.financial.domain.FinancialEvent;
//import io.swagger.v3.oas.annotations.tags.Tag;
//import lombok.RequiredArgsConstructor;
//import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
//import org.springframework.format.annotation.DateTimeFormat;
//import org.springframework.web.bind.annotation.*;
//
//import java.time.LocalDate;
//import java.util.List;
//import java.util.UUID;
//
//@RestController
//@RequestMapping("/api/v1/financial-provider/payway/polling")
//@RequiredArgsConstructor
//@ConditionalOnProperty(prefix = "lifeos.payway", name = "enabled", havingValue = "true")
//@Tag(name = "PayWay Polling", description = "Manual PayWay polling/recovery APIs")
//public class PayWayPollingAdminController {
//
//    private final PayWayPollingService pollingService;
//
//    @PostMapping("/poll/{userId}")
//    public ApiResponse<List<FinancialEvent>> poll(
//            @PathVariable UUID userId,
//            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
//            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate,
//            @RequestParam(defaultValue = "Asia/Phnom_Penh") String timezone
//    ) {
//        return ApiResponse.success(
//                pollingService.poll(userId, fromDate, toDate, timezone),
//                "PayWay polling completed"
//        );
//    }
//}