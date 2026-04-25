package com.lifeos.backend.user.api;

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

    @PostMapping("/demo")
    @Operation(summary = "Create demo user")
    public ApiResponse<UserResponse> createDemoUser() {
        return ApiResponse.success(userService.createDemoUser(), "Demo user created");
    }

    @GetMapping
    @Operation(summary = "Get all users")
    public ApiResponse<List<UserResponse>> getAll() {
        return ApiResponse.success(userService.getAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get user by id")
    public ApiResponse<UserResponse> getById(@PathVariable UUID id) {
        return ApiResponse.success(userService.getById(id));
    }

    @GetMapping("/profile/{id}")
    @Operation(summary = "Get user profile")
    public ApiResponse<UserResponse> getProfile(@PathVariable UUID id) {
        return ApiResponse.success(userService.getProfile(id));
    }

    @PutMapping("/profile/{id}")
    @Operation(summary = "Update user profile")
    public ApiResponse<UserResponse> updateProfile(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateUserProfileRequest request
    ) {
        return ApiResponse.success(userService.updateProfile(id, request), "User profile updated");
    }
}