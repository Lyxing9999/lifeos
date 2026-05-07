package com.lifeos.backend.auth.api.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AuthResponse {

    private String accessToken;
    private String tokenType;
    private Long expiresInSeconds;
    private AuthUserResponse user;
}