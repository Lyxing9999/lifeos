package com.lifeos.backend.auth.infrastructure.google;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Collections;

@Component
public class GoogleTokenVerifier {

    private final GoogleIdTokenVerifier verifier;

    public GoogleTokenVerifier(
            @Value("${lifeos.auth.google.client-id}") String googleClientId
    ) {
        this.verifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(),
                GsonFactory.getDefaultInstance()
        )
                .setAudience(Collections.singletonList(googleClientId))
                .build();
    }

    public GoogleUserInfo verify(String idToken) {
        try {
            GoogleIdToken verifiedToken = verifier.verify(idToken);

            if (verifiedToken == null) {
                throw new IllegalArgumentException("Invalid Google ID token");
            }

            GoogleIdToken.Payload payload = verifiedToken.getPayload();

            String subject = payload.getSubject();
            String email = payload.getEmail();
            Boolean emailVerified = payload.getEmailVerified();

            if (subject == null || subject.isBlank()) {
                throw new IllegalArgumentException("Google token missing subject");
            }

            if (email == null || email.isBlank()) {
                throw new IllegalArgumentException("Google token missing email");
            }

            Object nameValue = payload.get("name");
            Object pictureValue = payload.get("picture");

            return new GoogleUserInfo(
                    subject,
                    email,
                    nameValue != null ? nameValue.toString() : email,
                    pictureValue != null ? pictureValue.toString() : null,
                    Boolean.TRUE.equals(emailVerified)
            );
        } catch (Exception ex) {
            throw new IllegalArgumentException("Invalid Google ID token", ex);
        }
    }
}