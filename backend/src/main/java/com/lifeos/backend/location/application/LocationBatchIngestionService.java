//package com.lifeos.backend.location.application;
//
//import com.lifeos.backend.location.api.request.LocationBatchRequest;
//import com.lifeos.backend.location.api.request.LocationPointRequest;
//import com.lifeos.backend.location.api.response.LocationBatchIngestResponse;
//import com.lifeos.backend.location.domain.LocationLog;
//import com.lifeos.backend.location.domain.LocationLogRepository;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.stereotype.Service;
//
//import java.util.List;
//
//@Service
//@RequiredArgsConstructor
//@Slf4j
//public class LocationBatchIngestionService {
//
//    private static final double MAX_ACCEPTABLE_ACCURACY_METERS = 150.0;
//
//    private final LocationLogRepository repository;
//    private final LocationMapper mapper;
//
//    public LocationBatchIngestResponse ingest(LocationBatchRequest request) {
//        if (request == null || request.getUserId() == null || request.getPoints() == null || request.getPoints().isEmpty()) {
//            return LocationBatchIngestResponse.builder()
//                    .requestedPoints(0)
//                    .acceptedPoints(0)
//                    .rejectedPoints(0)
//                    .message("No points submitted")
//                    .build();
//        }
//
//        List<LocationLog> acceptedLogs = request.getPoints().stream()
//                .filter(this::isUsablePoint)
//                .map(point -> mapper.toEntity(request.getUserId(), point))
//                .toList();
//
//        repository.saveAll(acceptedLogs);
//
//        int requested = request.getPoints().size();
//        int accepted = acceptedLogs.size();
//        int rejected = requested - accepted;
//
//        log.info(
//                "location_batch_ingested userId={} requestedPoints={} acceptedPoints={} rejectedPoints={}",
//                request.getUserId(),
//                requested,
//                accepted,
//                rejected
//        );
//
//        return LocationBatchIngestResponse.builder()
//                .requestedPoints(requested)
//                .acceptedPoints(accepted)
//                .rejectedPoints(rejected)
//                .message("Location batch ingested successfully")
//                .build();
//    }
//
//    private boolean isUsablePoint(LocationPointRequest point) {
//        return point != null
//                && point.getLatitude() != null
//                && point.getLongitude() != null
//                && point.getRecordedAt() != null
//                && point.getAccuracyMeters() != null
//                && point.getAccuracyMeters() > 0
//                && point.getAccuracyMeters() <= MAX_ACCEPTABLE_ACCURACY_METERS;
//    }
//}