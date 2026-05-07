package com.lifeos.backend.auth.domain;

import java.util.UUID;

public record LifeOsPrincipal(
        UUID userId,
        String email
) {
}