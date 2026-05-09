package com.lifeos.backend.task.api.request;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class LifecycleReasonRequest {

    private UUID userId;
    private String reason;
}