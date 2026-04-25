package com.lifeos.backend.user.api.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateUserProfileRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String timezone;

    @NotBlank
    private String locale;
}