package com.lifeos.backend.auth.infrastructure.google;

public record GoogleUserInfo(
        String subject,
        String email,
        String name,
        String pictureUrl,
        Boolean emailVerified
) {
}