package com.lifeos.backend.location.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.common.util.ZoneDateUtils;
import com.lifeos.backend.location.api.response.LocationLogResponse;
import com.lifeos.backend.location.domain.LocationLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LocationLogService {

    private final LocationLogRepository repository;
    private final LocationMapper mapper;
    private final UserTimeService userTimeService;

    public List<LocationLogResponse> getByUserIdAndDay(UUID userId, LocalDate date) {
        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        return repository.findByUserIdAndRecordedAtBetween(
                        userId,
                        ZoneDateUtils.startOfDayUtc(date, zoneId),
                        ZoneDateUtils.endOfDayUtc(date, zoneId)
                ).stream()
                .map(mapper::toResponse)
                .toList();
    }
}