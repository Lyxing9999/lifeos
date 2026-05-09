package com.lifeos.backend.task.api.request;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class CompleteTaskRequest {

    private UUID userId;
}