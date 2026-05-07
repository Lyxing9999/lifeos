package com.lifeos.backend.auth.application;

import com.lifeos.backend.auth.domain.LifeOsPrincipal;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CurrentUserResolver {

    private final UserRepository userRepository;

    public UUID requireUserId(LifeOsPrincipal principal) {
        if (principal == null || principal.userId() == null) {
            throw new IllegalStateException("Authentication required");
        }

        return principal.userId();
    }

    public User requireUser(LifeOsPrincipal principal) {
        UUID userId = requireUserId(principal);

        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));
    }
}