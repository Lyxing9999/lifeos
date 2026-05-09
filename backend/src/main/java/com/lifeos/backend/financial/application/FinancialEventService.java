//package com.lifeos.backend.financial.application;
//
//import com.lifeos.backend.common.util.ZoneDateUtils;
//import com.lifeos.backend.financial.api.response.FinancialEventResponse;
//import com.lifeos.backend.financial.domain.FinancialEvent;
//import com.lifeos.backend.financial.domain.FinancialEventRepository;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//import java.time.LocalDate;
//import java.util.List;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//public class FinancialEventService {
//
//    private final FinancialEventRepository repository;
//    private final FinancialEventMapper mapper;
//
//    public List<FinancialEventResponse> getByUserIdAndDay(UUID userId, LocalDate date, String timezone) {
//        return repository.findByUserIdAndEventDateLocalOrderByPaidAtAsc(userId, date)
//                .stream()
//                .map(mapper::toResponse)
//                .toList();
//    }
//
//    public List<FinancialEventResponse> getByUserIdAndRange(
//            UUID userId,
//            LocalDate startDate,
//            LocalDate endDate,
//            String timezone
//    ) {
//        var zoneId = ZoneDateUtils.parseZoneId(timezone);
//
//        return repository.findByUserIdAndPaidAtBetweenOrderByPaidAtAsc(
//                        userId,
//                        ZoneDateUtils.startOfDayUtc(startDate, zoneId),
//                        ZoneDateUtils.endOfDayUtc(endDate, zoneId)
//                )
//                .stream()
//                .map(mapper::toResponse)
//                .toList();
//    }
//
//    public FinancialEventResponse getById(UUID id) {
//        return repository.findById(id)
//                .map(mapper::toResponse)
//                .orElseThrow(() -> new IllegalArgumentException("Financial event not found"));
//    }
//
//    public long countByUserIdAndDay(UUID userId, LocalDate date) {
//        return repository.countByUserIdAndEventDateLocal(userId, date);
//    }
//
//    public void delete(UUID id) {
//        repository.deleteById(id);
//    }
//
//    public FinancialEvent save(FinancialEvent event) {
//        return repository.save(event);
//    }
//}