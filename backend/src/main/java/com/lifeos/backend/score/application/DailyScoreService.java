
// we skip supporting domain for now
//package com.lifeos.backend.score.application;
//
//import com.lifeos.backend.common.exception.NotFoundException;
//import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
//import com.lifeos.backend.schedule.application.ScheduleQueryService;
//import com.lifeos.backend.score.api.response.DailyScoreResponse;
//import com.lifeos.backend.score.domain.DailyScore;
//import com.lifeos.backend.score.domain.DailyScoreRepository;
//import com.lifeos.backend.score.infrastructure.calculator.DailyScoreCalculator;
//import com.lifeos.backend.staysession.api.response.StaySessionResponse;
//import com.lifeos.backend.staysession.application.StaySessionService;
//import com.lifeos.backend.task.api.response.TaskResponse;
//import com.lifeos.backend.task.application.query.TaskQueryService;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.stereotype.Service;
//
//import java.time.LocalDate;
//import java.util.List;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//@Slf4j
//public class DailyScoreService {
//
//        private final DailyScoreRepository repository;
//        private final TaskQueryService taskQueryService;
//        private final ScheduleQueryService scheduleQueryService;
//        private final StaySessionService staySessionService;
//        private final DailyScoreCalculator dailyScoreCalculator;
//
//        public DailyScoreResponse generate(UUID userId, LocalDate date) {
//                List<TaskResponse> relevantTasks = taskQueryService.getDayTruthTasks(
//                                userId,
//                                date);
//
//                List<ScheduleOccurrenceResponse> schedules = scheduleQueryService.getOccurrencesForDay(userId, date);
//
//                List<StaySessionResponse> staySessions = staySessionService.getByUserIdAndDay(userId, date);
//
//                repository.findByUserIdAndScoreDate(userId, date)
//                                .ifPresent(repository::delete);
//
//                DailyScore score = dailyScoreCalculator.calculate(
//                                userId,
//                                date,
//                                relevantTasks,
//                                schedules,
//                                staySessions);
//
//                DailyScore saved = repository.save(score);
//
//                log.info(
//                                "daily_score_generated userId={} date={} totalTasks={} completedTasks={} totalPlannedBlocks={} totalStaySessions={} completionScore={} structureScore={} overallScore={}",
//                                userId,
//                                date,
//                                saved.getTotalTasks(),
//                                saved.getCompletedTasks(),
//                                saved.getTotalPlannedBlocks(),
//                                saved.getTotalStaySessions(),
//                                saved.getCompletionScore(),
//                                saved.getStructureScore(),
//                                saved.getOverallScore());
//
//                return toResponse(saved);
//        }
//
//        public DailyScoreResponse get(UUID userId, LocalDate date) {
//                DailyScore score = repository.findByUserIdAndScoreDate(userId, date)
//                                .orElseThrow(() -> new NotFoundException("Daily score not found"));
//                return toResponse(score);
//        }
//
//        public void delete(UUID userId, LocalDate date) {
//                DailyScore score = repository.findByUserIdAndScoreDate(userId, date)
//                                .orElseThrow(() -> new NotFoundException("Daily score not found"));
//
//                repository.delete(score);
//
//                log.info("daily_score_deleted userId={} date={}", userId, date);
//        }
//
//        private DailyScoreResponse toResponse(DailyScore score) {
//                return DailyScoreResponse.builder()
//                                .id(score.getId())
//                                .userId(score.getUserId())
//                                .scoreDate(score.getScoreDate())
//                                .completionScore(score.getCompletionScore())
//                                .structureScore(score.getStructureScore())
//                                .overallScore(score.getOverallScore())
//                                .completedTasks(score.getCompletedTasks())
//                                .totalTasks(score.getTotalTasks())
//                                .totalPlannedBlocks(score.getTotalPlannedBlocks())
//                                .totalStaySessions(score.getTotalStaySessions())
//                                .scoreExplanation(score.getScoreExplanation())
//                                .build();
//        }
//}