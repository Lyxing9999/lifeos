package com.lifeos.backend.schedule.application.policy;


//TODO we reuse later
public record PolicyValidation(
        boolean valid,
        String reason
) {
    public static PolicyValidation ok() {
        return new PolicyValidation(true, null);
    }

    public static PolicyValidation invalid(String reason) {
        return new PolicyValidation(false, reason);
    }
}