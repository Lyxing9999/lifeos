package com.lifeos.backend.auth.application;

import com.lifeos.backend.auth.domain.LifeOsPrincipal;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class CurrentUserService {

    public LifeOsPrincipal getPrincipal() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new AuthenticationCredentialsNotFoundException("Unauthorized");
        }

        Object principal = authentication.getPrincipal();

        if (!(principal instanceof LifeOsPrincipal lifeOsPrincipal)) {
            throw new AuthenticationCredentialsNotFoundException("Unauthorized");
        }

        return lifeOsPrincipal;
    }

    public UUID getUserId() {
        return getPrincipal().userId();
    }

    public String getEmail() {
        return getPrincipal().email();
    }
}