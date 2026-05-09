//package com.lifeos.backend.financial.infrastructure.provider.payway.polling;
//
//import com.lifeos.backend.common.config.PayWayProperties;
//import com.lifeos.backend.financial.application.FinancialIngestionService;
//import com.lifeos.backend.financial.domain.FinancialEvent;
//import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderContext;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
//import org.springframework.stereotype.Service;
//
//import java.time.LocalDate;
//import java.time.LocalDateTime;
//import java.time.ZoneOffset;
//import java.time.format.DateTimeFormatter;
//import java.util.ArrayList;
//import java.util.List;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//@Slf4j
//@ConditionalOnProperty(prefix = "lifeos.payway", name = "enabled", havingValue = "true")
//public class PayWayPollingService {
//
//    private static final DateTimeFormatter REQ_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
//    private static final DateTimeFormatter QUERY_DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
//
//    private final PayWayProperties properties;
//    private final PayWayTransactionListHashService hashService;
//    private final PayWayTransactionListClient client;
//    private final PayWayTransactionMapper mapper;
//    private final FinancialIngestionService ingestionService;
//
//    public List<FinancialEvent> poll(UUID userId, LocalDate fromDate, LocalDate toDate, String timezone) {
//        List<FinancialEvent> saved = new ArrayList<>();
//
//        String reqTime = LocalDateTime.now(ZoneOffset.UTC).format(REQ_TIME_FORMAT);
//
//        String fromDateTime = fromDate.atStartOfDay().format(QUERY_DATE_FORMAT);
//        String toDateTime = toDate.atTime(23, 59, 59).format(QUERY_DATE_FORMAT);
//
//        PayWayTransactionListRequest request = PayWayTransactionListRequest.builder()
//                .reqTime(reqTime)
//                .merchantId(properties.getMerchantId())
//                .fromDate(fromDateTime)
//                .toDate(toDateTime)
//                .fromAmount("0.01")
//                .toAmount("999999999")
//                .status("APPROVED,REFUNDED,PENDING,PRE-AUTH")
//                .page("1")
//                .pagination("100")
//                .build();
//
//        request.setHash(hashService.generateHash(request));
//
//        log.info("payway_polling_request userId={} fromDate={} toDate={}", userId, fromDate, toDate);
//
//        PayWayTransactionListResponse response = client.fetch(request);
//
//        if (response.getStatus() == null || !"00".equals(response.getStatus().getCode())) {
//            throw new IllegalStateException("PayWay polling failed: " +
//                    (response.getStatus() == null ? "missing status" : response.getStatus().getMessage()));
//        }
//
//        if (response.getData() == null || response.getData().isEmpty()) {
//            return saved;
//        }
//
//        FinancialProviderContext context = new FinancialProviderContext(
//                userId,
//                timezone,
//                "payway-polling-" + userId
//        );
//
//        for (PayWayTransactionListResponse.Item item : response.getData()) {
//            saved.add(
//                    ingestionService.ingest(
//                            mapper.map(item, context)
//                    )
//            );
//        }
//
//        log.info("payway_polling_imported_count={}", saved.size());
//        return saved;
//    }
//}