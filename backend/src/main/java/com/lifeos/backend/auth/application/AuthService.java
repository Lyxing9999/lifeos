package com.lifeos.backend.auth.application;

import com.lifeos.backend.auth.api.request.GoogleLoginRequest;
import com.lifeos.backend.auth.api.response.AuthResponse;
import com.lifeos.backend.auth.api.response.AuthUserResponse;
import com.lifeos.backend.auth.domain.LifeOsPrincipal;
import com.lifeos.backend.auth.infrastructure.google.GoogleTokenVerifier;
import com.lifeos.backend.auth.infrastructure.google.GoogleUserInfo;
import com.lifeos.backend.auth.infrastructure.jwt.JwtService;
import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final GoogleTokenVerifier googleTokenVerifier;
    private final JwtService jwtService;
    private final UserRepository userRepository;

    public AuthResponse loginWithGoogle(GoogleLoginRequest request) {
        GoogleUserInfo googleUser = googleTokenVerifier.verify(request.getIdToken());

        User user = userRepository.findByGoogleSubject(googleUser.subject())
                .or(() -> userRepository.findByEmail(googleUser.email()))
                .map(existing -> updateExistingUser(existing, googleUser, request.getTimezone()))
                .orElseGet(() -> createUser(googleUser, request.getTimezone()));

        User saved = userRepository.save(user);

        String accessToken = jwtService.createAccessToken(saved.getId(), saved.getEmail());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .tokenType("Bearer")
                .expiresInSeconds(jwtService.expirationSeconds())
                .user(toAuthUserResponse(saved))
                .build();
    }

    public AuthUserResponse getCurrentUser(LifeOsPrincipal principal) {
        User user = userRepository.findById(principal.userId())
                .orElseThrow(() -> new NotFoundException("User not found"));

        return toAuthUserResponse(user);
    }

    private User createUser(GoogleUserInfo googleUser, String timezone) {
        User user = new User();
        user.setEmail(googleUser.email());
        user.setName(googleUser.name());
        user.setPictureUrl(googleUser.pictureUrl());
        user.setGoogleSubject(googleUser.subject());
        user.setEmailVerified(Boolean.TRUE.equals(googleUser.emailVerified()));
        user.setTimezone(normalizeTimezone(timezone));
        user.setActive(true);
        return user;
    }

    private User updateExistingUser(User user, GoogleUserInfo googleUser, String timezone) {
        user.setEmail(googleUser.email());
        user.setName(googleUser.name());
        user.setPictureUrl(googleUser.pictureUrl());
        user.setGoogleSubject(googleUser.subject());
        user.setEmailVerified(Boolean.TRUE.equals(googleUser.emailVerified()));

        if (timezone != null && !timezone.isBlank()) {
            user.setTimezone(normalizeTimezone(timezone));
        }

        if (user.getActive() == null) {
            user.setActive(true);
        }

        return user;
    }

    private String normalizeTimezone(String timezone) {
        if (timezone == null || timezone.isBlank()) {
            return "Asia/Phnom_Penh";
        }

        return timezone.trim();
    }

    private AuthUserResponse toAuthUserResponse(User user) {
        return AuthUserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .pictureUrl(user.getPictureUrl())
                .timezone(user.getTimezone())
                .build();
    }
}