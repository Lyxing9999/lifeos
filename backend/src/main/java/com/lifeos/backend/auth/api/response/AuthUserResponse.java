package com.lifeos.backend.auth.api.response;

import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@Getter
@Builder
public class AuthUserResponse {

    private UUID id;
    private String email;
    private String name;
    private String pictureUrl;
    private String timezone;
}