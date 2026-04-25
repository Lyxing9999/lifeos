package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.lifeos.backend.config.PayWayProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Service
@RequiredArgsConstructor
@Slf4j
public class PayWayCreateLinkHashService {

    private final PayWayProperties properties;

    public String generateHash(String requestTime, String merchantId, String merchantAuth) {
        String payload = requestTime + merchantId + merchantAuth;
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(properties.getApiKey().getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            String hash = Base64.getEncoder().encodeToString(mac.doFinal(payload.getBytes(StandardCharsets.UTF_8)));
            log.info("payway_create_link_hash_payload_length={}", payload.length());
            return hash;
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to generate PayWay create-link hash", ex);
        }
    }
}