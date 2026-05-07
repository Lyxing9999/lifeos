package com.lifeos.backend.user;

import com.lifeos.backend.support.BaseE2ETest;
import com.lifeos.backend.user.api.request.UpdateUserProfileRequest;
import com.lifeos.backend.user.domain.User;
import org.junit.jupiter.api.Test;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
class UserControllerE2ETest extends BaseE2ETest {

    @Test
    void getMe_withAuth_shouldReturnAuthenticatedUser() throws Exception {
        User user = testDataHelper.createUser();

        mockMvc.perform(get("/api/v1/users/me")
                        .header("Authorization", authTestHelper.bearer(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(user.getId().toString()))
                .andExpect(jsonPath("$.data.email").value(user.getEmail()))
                .andExpect(jsonPath("$.data.name").value(user.getName()))
                .andExpect(jsonPath("$.data.timezone").value(user.getTimezone()))
                .andExpect(jsonPath("$.data.locale").value(user.getLocale()));
    }

    @Test
    void getMe_withoutAuth_shouldReturnUnauthorized() throws Exception {
        mockMvc.perform(get("/api/v1/users/me"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void updateMe_withAuth_shouldUpdateAuthenticatedUserProfile() throws Exception {
        User user = testDataHelper.createUser();

        UpdateUserProfileRequest request = new UpdateUserProfileRequest();
        request.setName("Updated User");
        request.setTimezone("Asia/Phnom_Penh");
        request.setLocale("km");

        mockMvc.perform(put("/api/v1/users/me")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(user.getId().toString()))
                .andExpect(jsonPath("$.data.name").value("Updated User"))
                .andExpect(jsonPath("$.data.timezone").value("Asia/Phnom_Penh"))
                .andExpect(jsonPath("$.data.locale").value("km"));
    }

    @Test
    void updateMe_withoutAuth_shouldReturnUnauthorized() throws Exception {
        UpdateUserProfileRequest request = new UpdateUserProfileRequest();
        request.setName("Updated User");
        request.setTimezone("Asia/Phnom_Penh");
        request.setLocale("km");

        mockMvc.perform(put("/api/v1/users/me")
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void updateMe_withInvalidBody_shouldReturnBadRequest() throws Exception {
        User user = testDataHelper.createUser();

        UpdateUserProfileRequest request = new UpdateUserProfileRequest();
        request.setName("");
        request.setTimezone("");
        request.setLocale("");

        mockMvc.perform(put("/api/v1/users/me")
                        .header("Authorization", authTestHelper.bearer(user))
                        .contentType(json)
                        .content(toJson(request)))
                .andExpect(status().isBadRequest());
    }

    @Test

    void deprecatedProfilePath_shouldIgnorePathIdAndUseAuthenticatedUser() throws Exception {

        User realUser = testDataHelper.createUser();

        User otherUser = testDataHelper.createUser();

        mockMvc.perform(get("/api/v1/users/profile/{id}", otherUser.getId())

                        .header("Authorization", authTestHelper.bearer(realUser)))

                .andExpect(status().isOk())

                .andExpect(jsonPath("$.success").value(true))

                .andExpect(jsonPath("$.data.id").value(realUser.getId().toString()))

                .andExpect(jsonPath("$.data.email").value(realUser.getEmail()));

    }
}