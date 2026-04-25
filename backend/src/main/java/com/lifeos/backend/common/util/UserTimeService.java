package com.lifeos.backend.common.util;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.ZoneId;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class UserTimeService {

    private final UserRepository userRepository;

    public ZoneId getUserZoneId(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));

        return ZoneDateUtils.parseZoneId(user.getTimezone());
    }
}