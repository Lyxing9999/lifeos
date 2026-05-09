//package com.lifeos.backend.staysession.application;
//
//import com.lifeos.backend.common.util.UserTimeService;
//import com.lifeos.backend.common.util.ZoneDateUtils;
//import com.lifeos.backend.staysession.application.StayDetectionService;
//import com.lifeos.backend.staysession.domain.StaySessionRepository;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.stereotype.Service;
//
//import java.time.LocalDate;
//import java.time.ZoneId;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//@Slf4j
//public class StaySessionRebuildService {
//
//    private final StaySessionRepository repository;
//    private final UserTimeService userTimeService;
//    private final StayDetectionService stayDetectionService;
//
//    public int rebuildDay(UUID userId, LocalDate date) {
//        ZoneId zoneId = userTimeService.getUserZoneId(userId);
//
//        var dayStart = ZoneDateUtils.startOfDayUtc(date, zoneId);
//        var dayEnd = ZoneDateUtils.endOfDayUtc(date, zoneId);
//
//        repository.deleteByUserIdAndStartTimeBetween(userId, dayStart, dayEnd);
//
//        int created = stayDetectionService.detectForDay(userId, dayStart, dayEnd);
//
//        log.info(
//                "stay_session_day_rebuilt userId={} date={} createdSessions={}",
//                userId,
//                date,
//                created
//        );
//
//        return created;
//    }
//
//    public void deleteDay(UUID userId, LocalDate date) {
//        ZoneId zoneId = userTimeService.getUserZoneId(userId);
//
//        repository.deleteByUserIdAndStartTimeBetween(
//                userId,
//                ZoneDateUtils.startOfDayUtc(date, zoneId),
//                ZoneDateUtils.endOfDayUtc(date, zoneId)
//        );
//
//        log.info("stay_session_day_deleted userId={} date={}", userId, date);
//    }
//}