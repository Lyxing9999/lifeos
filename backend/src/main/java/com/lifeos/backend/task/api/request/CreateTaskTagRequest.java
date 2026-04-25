package com.lifeos.backend.task.api.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class CreateTaskTagRequest {

    @NotNull
    private UUID userId;

    @NotBlank
    private String name;

    private String colorHex;
}