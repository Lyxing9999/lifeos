package com.lifeos.backend.auth.api;

import com.lifeos.backend.auth.api.request.GoogleLoginRequest;
import com.lifeos.backend.auth.api.response.AuthResponse;
import com.lifeos.backend.auth.api.response.AuthUserResponse;
import com.lifeos.backend.auth.application.AuthService;
import com.lifeos.backend.auth.domain.LifeOsPrincipal;
import com.lifeos.backend.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/google")
    public ApiResponse<AuthResponse> loginWithGoogle(
            @Valid @RequestBody GoogleLoginRequest request
    ) {
        return ApiResponse.success(
                authService.loginWithGoogle(request),
                "Google login successful"
        );
    }

    @GetMapping("/me")
    public ApiResponse<AuthUserResponse> me(
            @AuthenticationPrincipal LifeOsPrincipal principal
    ) {
        return ApiResponse.success(authService.getCurrentUser(principal));
    }
}