//package com.lifeos.backend.staysession.application;
//
//import com.lifeos.backend.common.util.UserTimeService;
//import com.lifeos.backend.common.util.ZoneDateUtils;
//import com.lifeos.backend.staysession.api.response.StaySessionResponse;
//import com.lifeos.backend.staysession.domain.StaySessionRepository;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//import java.time.LocalDate;
//import java.time.ZoneId;
//import java.util.List;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//public class StaySessionService {
//
//    private final StaySessionRepository repository;
//    private final StaySessionMapper mapper;
//    private final UserTimeService userTimeService;
//
//    public List<StaySessionResponse> getByUserIdAndDay(UUID userId, LocalDate date) {
//        ZoneId zoneId = userTimeService.getUserZoneId(userId);
//
//        return repository.findByUserIdAndStartTimeBetween(
//                        userId,
//                        ZoneDateUtils.startOfDayUtc(date, zoneId),
//                        ZoneDateUtils.endOfDayUtc(date, zoneId)
//                ).stream()
//                .map(mapper::toResponse)
//                .toList();
//    }
//}