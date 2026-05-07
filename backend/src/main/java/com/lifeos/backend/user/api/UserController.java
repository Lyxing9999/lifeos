package com.lifeos.backend.user.api;

import com.lifeos.backend.auth.application.CurrentUserService;
import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.user.api.request.UpdateUserProfileRequest;
import com.lifeos.backend.user.api.response.UserResponse;
import com.lifeos.backend.user.application.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User APIs")
public class UserController {

    private final UserService userService;
    private final CurrentUserService currentUserService;

    @GetMapping("/me")
    @Operation(summary = "Get authenticated user profile")
    public ApiResponse<UserResponse> getMe() {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(userService.getProfile(userId));
    }

    @PutMapping("/me")
    @Operation(summary = "Update authenticated user profile")
    public ApiResponse<UserResponse> updateMe(
            @Valid @RequestBody UpdateUserProfileRequest request
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(
                userService.updateProfile(userId, request),
                "User profile updated"
        );
    }

    /*
     * Temporary/demo endpoint.
     * Keep only for local development if still needed.
     */
    @PostMapping("/demo")
    @Operation(summary = "Create demo user")
    public ApiResponse<UserResponse> createDemoUser() {
        return ApiResponse.success(userService.createDemoUser(), "Demo user created");
    }

    /*
     * Deprecated/admin-style endpoints.
     * Keep temporarily while frontend migrates to /me.
     */

    @Deprecated
    @GetMapping
    @Operation(summary = "Deprecated/admin: Get all users", deprecated = true)
    public ApiResponse<List<UserResponse>> getAll() {
        return ApiResponse.success(userService.getAll());
    }

    @Deprecated
    @GetMapping("/{id}")
    @Operation(summary = "Deprecated: use /api/v1/users/me", deprecated = true)
    public ApiResponse<UserResponse> getById(@PathVariable UUID id) {
        UUID authenticatedUserId = currentUserService.getUserId();
        return ApiResponse.success(userService.getById(authenticatedUserId));
    }

    @Deprecated
    @GetMapping("/profile/{id}")
    @Operation(summary = "Deprecated: use /api/v1/users/me", deprecated = true)
    public ApiResponse<UserResponse> getProfile(@PathVariable UUID id) {
        UUID authenticatedUserId = currentUserService.getUserId();
        return ApiResponse.success(userService.getProfile(authenticatedUserId));
    }

    @Deprecated
    @PutMapping("/profile/{id}")
    @Operation(summary = "Deprecated: use /api/v1/users/me", deprecated = true)
    public ApiResponse<UserResponse> updateProfile(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateUserProfileRequest request
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();

        return ApiResponse.success(
                userService.updateProfile(authenticatedUserId, request),
                "User profile updated"
        );
    }
}