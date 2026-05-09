//package com.lifeos.backend.financial.application;
//
//import com.lifeos.backend.common.util.ZoneDateUtils;
//import com.lifeos.backend.financial.domain.FinancialEvent;
//import com.lifeos.backend.financial.domain.FinancialEventRepository;
//import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderEvent;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//@Service
//@RequiredArgsConstructor
//public class FinancialIngestionService {
//
//    private final FinancialEventRepository repository;
//    private final FinancialClassificationService classificationService;
//
//    public FinancialEvent ingest(FinancialProviderEvent event) {
//        FinancialEvent entity = (event.providerEventId() != null && !event.providerEventId().isBlank())
//                ? repository.findByUserIdAndProviderEventId(event.userId(), event.providerEventId()).orElse(new FinancialEvent())
//                : new FinancialEvent();
//
//        entity.setUserId(event.userId());
//        entity.setAmount(event.amount());
//        entity.setCurrency(event.currency());
//        entity.setMerchantName(event.merchantName());
//        entity.setNormalizedMerchantName(classificationService.normalizeMerchantName(event.merchantName()));
//        entity.setMerchantConfidence(classificationService.merchantConfidence(event.merchantName()));
//        entity.setFinancialEventType(event.financialEventType());
//        entity.setCategory(event.category() == null
//                ? classificationService.inferCategory(event.merchantName(), event.description(), event.amount())
//                : event.category());
//        entity.setPaidAt(event.paidAt());
//        entity.setTimezone(event.timezone());
//        entity.setEventDateLocal(
//                ZoneDateUtils.toUserLocalDate(
//                        event.paidAt(),
//                        ZoneDateUtils.parseZoneId(event.timezone())
//                )
//        );
//        entity.setStatus(event.status());
//        entity.setSourceProvider(event.sourceProvider());
//        entity.setProviderEventId(event.providerEventId());
//        entity.setSourceAccountIdMasked(event.sourceAccountIdMasked());
//        entity.setRawReference(event.rawReference());
//        entity.setDescription(event.description());
//        entity.setLocationText(event.locationText());
//        entity.setCountryCode(event.countryCode());
//        entity.setIsReadOnly(event.isReadOnly());
//        entity.setConsentId(event.consentId());
//
//        return repository.save(entity);
//    }
//}