package com.lifeos.backend.task.api.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateTaskProgressRequest {

    @Min(0)
    @Max(100)
    private Integer progressPercent;
}