package com.lifeos.backend.staysession.application;

import com.lifeos.backend.location.domain.LocationLog;
import com.lifeos.backend.location.domain.LocationLogRepository;
import com.lifeos.backend.place.application.PlaceMatchingResult;
import com.lifeos.backend.place.application.PlaceMatchingService;
import com.lifeos.backend.staysession.application.StaySessionWriteService;
import com.lifeos.backend.staysession.domain.StaySession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Duration;  
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class StayDetectionService {

    /**
     * Max cluster radius for a stay candidate.
     */
    private static final double STAY_RADIUS_METERS = 120.0;

    /**
     * Minimum duration required to become a stay session.
     */
    private static final long MIN_STAY_MINUTES = 10L;

    /**
     * Minimum number of points required for a stay candidate.
     */
    private static final int MIN_POINTS_PER_STAY = 2;

    private final LocationLogRepository locationLogRepository;
    private final PlaceMatchingService placeMatchingService;
    private final StaySessionWriteService staySessionWriteService;

    public int detectForDay(UUID userId, Instant dayStart, Instant dayEnd) {
        List<LocationLog> logs = locationLogRepository.findByUserIdAndRecordedAtBetween(userId, dayStart, dayEnd)
                .stream()
                .sorted(Comparator.comparing(LocationLog::getRecordedAt))
                .toList();

        if (logs.size() < MIN_POINTS_PER_STAY) {
            log.info(
                    "stay_detection_skipped_insufficient_logs userId={} logCount={} dayStart={} dayEnd={}",
                    userId,
                    logs.size(),
                    dayStart,
                    dayEnd
            );
            return 0;
        }

        List<StaySession> detectedSessions = new ArrayList<>();

        int startIndex = 0;

        while (startIndex < logs.size() - 1) {
            List<LocationLog> cluster = new ArrayList<>();
            cluster.add(logs.get(startIndex));

            int endIndex = startIndex;

            while (endIndex + 1 < logs.size()) {
                LocationLog anchor = logs.get(startIndex);
                LocationLog candidate = logs.get(endIndex + 1);

                double distance = distanceMeters(
                        anchor.getLatitude(),
                        anchor.getLongitude(),
                        candidate.getLatitude(),
                        candidate.getLongitude()
                );

                if (distance <= STAY_RADIUS_METERS) {
                    cluster.add(candidate);
                    endIndex++;
                } else {
                    break;
                }
            }

            if (isValidStayCluster(cluster)) {
                StaySession session = buildStaySession(userId, cluster);
                if (session != null) {
                    detectedSessions.add(session);
                }
            }

            startIndex = Math.max(endIndex + 1, startIndex + 1);
        }

        if (detectedSessions.isEmpty()) {
            log.info(
                    "stay_detection_completed_no_sessions userId={} logCount={} dayStart={} dayEnd={}",
                    userId,
                    logs.size(),
                    dayStart,
                    dayEnd
            );
            return 0;
        }

        staySessionWriteService.saveAll(detectedSessions);

        log.info(
                "stay_detection_completed userId={} detectedSessions={} logCount={} dayStart={} dayEnd={}",
                userId,
                detectedSessions.size(),
                logs.size(),
                dayStart,
                dayEnd
        );

        return detectedSessions.size();
    }

    private boolean isValidStayCluster(List<LocationLog> cluster) {
        if (cluster == null || cluster.size() < MIN_POINTS_PER_STAY) {
            return false;
        }

        Instant start = cluster.get(0).getRecordedAt();
        Instant end = cluster.get(cluster.size() - 1).getRecordedAt();

        long durationMinutes = Duration.between(start, end).toMinutes();

        return durationMinutes >= MIN_STAY_MINUTES;
    }

    private StaySession buildStaySession(UUID userId, List<LocationLog> cluster) {
        if (cluster == null || cluster.isEmpty()) {
            return null;
        }

        Instant start = cluster.get(0).getRecordedAt();
        Instant end = cluster.get(cluster.size() - 1).getRecordedAt();
        long durationMinutes = Duration.between(start, end).toMinutes();

        if (durationMinutes < MIN_STAY_MINUTES) {
            return null;
        }

        double centerLat = averageLatitude(cluster);
        double centerLng = averageLongitude(cluster);

        PlaceMatchingResult match = placeMatchingService.match(
                userId,
                centerLat,
                centerLng,
                durationMinutes
        );

        StaySession session = new StaySession();
        session.setUserId(userId);
        session.setStartTime(start);
        session.setEndTime(end);
        session.setDurationMinutes(durationMinutes);
        session.setCenterLat(centerLat);
        session.setCenterLng(centerLng);
        session.setPlaceName(match != null ? match.getPlaceName() : "Unknown Place");
        session.setPlaceType(match != null ? match.getPlaceType() : "OTHER");
        session.setMatchedPlaceSource(match != null ? match.getSource() : "UNKNOWN");
        session.setConfidence(match != null ? match.getConfidence() : 0.2);

        return session;
    }

    private double averageLatitude(List<LocationLog> logs) {
        return logs.stream()
                .mapToDouble(LocationLog::getLatitude)
                .average()
                .orElse(0.0);
    }

    private double averageLongitude(List<LocationLog> logs) {
        return logs.stream()
                .mapToDouble(LocationLog::getLongitude)
                .average()
                .orElse(0.0);
    }

    private double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
        double earthRadius = 6371000.0;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);

        double a =
                Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                        Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                                Math.sin(dLng / 2) * Math.sin(dLng / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return earthRadius * c;
    }
}