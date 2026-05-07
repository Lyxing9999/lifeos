package com.lifeos.backend.user.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.user.api.request.UpdateUserProfileRequest;
import com.lifeos.backend.user.api.response.UserResponse;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public UserResponse createDemoUser() {
        String demoEmail = "kaingbunly1168@gmail.com";

        User user = userRepository.findByEmail(demoEmail).orElseGet(() -> {
            User newUser = new User();
            newUser.setName("Kaing Bunly");
            newUser.setEmail(demoEmail);
            newUser.setTimezone("Asia/Phnom_Penh");
            newUser.setLocale("en");
            return userRepository.save(newUser);
        });

        return toResponse(user);
    }
    public UserResponse getById(UUID id) {
        return toResponse(findEntity(id));
    }

    public UserResponse getProfile(UUID id) {
        return toResponse(findEntity(id));
    }

    public UserResponse updateProfile(UUID id, UpdateUserProfileRequest request) {
        User user = findEntity(id);
        user.setName(request.getName());
        user.setTimezone(request.getTimezone());
        user.setLocale(request.getLocale());
        return toResponse(userRepository.save(user));
    }

    public List<UserResponse> getAll() {
        return userRepository.findAll().stream().map(this::toResponse).toList();
    }

    private User findEntity(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User not found"));
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .timezone(user.getTimezone())
                .locale(user.getLocale())
                .build();
    }
}