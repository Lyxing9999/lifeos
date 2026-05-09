//package com.lifeos.backend.location.application;
//
//import com.lifeos.backend.location.api.request.LocationPointRequest;
//import com.lifeos.backend.location.api.response.LocationLogResponse;
//import com.lifeos.backend.location.domain.LocationLog;
//import com.lifeos.backend.location.domain.LocationSource;
//import org.springframework.stereotype.Component;
//
//@Component
//public class LocationMapper {
//
//    public LocationLog toEntity(java.util.UUID userId, LocationPointRequest point) {
//        LocationLog log = new LocationLog();
//        log.setUserId(userId);
//        log.setLatitude(point.getLatitude());
//        log.setLongitude(point.getLongitude());
//        log.setAccuracyMeters(point.getAccuracyMeters());
//        log.setSpeedMetersPerSecond(point.getSpeedMetersPerSecond());
//        log.setRecordedAt(point.getRecordedAt());
//        log.setSource(parseSource(point.getSource()));
//        return log;
//    }
//
//    public LocationLogResponse toResponse(LocationLog log) {
//        return LocationLogResponse.builder()
//                .id(log.getId())
//                .userId(log.getUserId())
//                .latitude(log.getLatitude())
//                .longitude(log.getLongitude())
//                .accuracyMeters(log.getAccuracyMeters())
//                .speedMetersPerSecond(log.getSpeedMetersPerSecond())
//                .recordedAt(log.getRecordedAt())
//                .source(log.getSource() != null ? log.getSource().name() : null)
//                .build();
//    }
//
//    private LocationSource parseSource(String source) {
//        if (source == null || source.isBlank()) {
//            return LocationSource.MOBILE_BACKGROUND;
//        }
//
//        try {
//            return LocationSource.valueOf(source.trim().toUpperCase());
//        } catch (Exception ex) {
//            return LocationSource.OTHER;
//        }
//    }
//}