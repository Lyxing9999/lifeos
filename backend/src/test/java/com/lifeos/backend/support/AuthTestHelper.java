package com.lifeos.backend.support;

import com.lifeos.backend.auth.infrastructure.jwt.JwtService;
import com.lifeos.backend.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AuthTestHelper {

    private final JwtService jwtService;

    public String bearer(User user) {
        String token = jwtService.createAccessToken(user.getId(), user.getEmail());
        return "Bearer " + token;
    }
}