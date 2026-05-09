package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.lifeos.backend.common.config.PayWayProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

@Service
@RequiredArgsConstructor
public class PayWayKeyLoaderService {

    private final PayWayProperties properties;

    public PublicKey loadPublicKey() {
        try {
            String pem = properties.getRsaPublicKey();
            String normalized = pem
                    .replace("-----BEGIN PUBLIC KEY-----", "")
                    .replace("-----END PUBLIC KEY-----", "")
                    .replace("\\n", "")
                    .replace("\n", "")
                    .replace("\r", "")
                    .trim();

            byte[] decoded = Base64.getDecoder().decode(normalized);
            return KeyFactory.getInstance("RSA")
                    .generatePublic(new X509EncodedKeySpec(decoded));
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to load PayWay RSA public key", ex);
        }
    }
}