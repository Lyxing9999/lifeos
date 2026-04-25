package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lifeos.backend.config.PayWayProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.PublicKey;
import java.time.Instant;
import java.time.ZonedDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Base64;

@Service
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(prefix = "lifeos.payway", name = "enabled", havingValue = "true")
public class PayWayCreatePaymentLinkService {

    private final PayWayProperties properties;
    private final ObjectMapper objectMapper;
    private final PayWayRsaService rsaService;
    private final PayWayKeyLoaderService keyLoaderService;
    private final PayWayCreateLinkHashService hashService;

    public PayWayCreatePaymentLinkResponse create(CreatePayWayPaymentLinkRequest request, String callbackUserId) {
        try {
            String requestTime = ZonedDateTime.now(ZoneOffset.UTC)
                    .format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));

            String callbackUrl = "https://deepness-reason-remover.ngrok-free.dev/api/v1/financial-provider/payway/callback/" + callbackUserId;
            String callbackUrlBase64 = Base64.getEncoder().encodeToString(callbackUrl.getBytes(StandardCharsets.UTF_8));

            PayWayCreatePaymentLinkMerchantAuthPayload payload =
                    PayWayCreatePaymentLinkMerchantAuthPayload.builder()
                            .mcId(properties.getMerchantId())
                            .title(request.getTitle())
                            .amount(request.getAmount())
                            .currency(request.getCurrency())
                            .description(request.getDescription())
                            .paymentLimit(request.getPaymentLimit() == null || request.getPaymentLimit().isBlank() ? "1" : request.getPaymentLimit())
                            .expiredDate(request.getExpiredDate() == null || request.getExpiredDate().isBlank()
                                    ? String.valueOf(Instant.now().plusSeconds(86400).getEpochSecond())
                                    : request.getExpiredDate())
                            .returnUrl(callbackUrlBase64)
                            .merchantRefNo(request.getMerchantRefNo() == null || request.getMerchantRefNo().isBlank()
                                    ? "lifeos-" + System.currentTimeMillis()
                                    : request.getMerchantRefNo())
                            .build();

            String merchantAuthJson = objectMapper.writeValueAsString(payload);
            PublicKey publicKey = keyLoaderService.loadPublicKey();
            String merchantAuth = rsaService.encryptLongText(merchantAuthJson, publicKey);
            String hash = hashService.generateHash(requestTime, properties.getMerchantId(), merchantAuth);

            log.info("payway_create_link_request_time={}", requestTime);
            log.info("payway_create_link_merchant_auth_json={}", merchantAuthJson);

            RequestBody body = new MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart("request_time", requestTime)
                    .addFormDataPart("merchant_id", properties.getMerchantId())
                    .addFormDataPart("merchant_auth", merchantAuth)
                    .addFormDataPart("hash", hash)
                    .build();

            OkHttpClient client = new OkHttpClient.Builder().build();
            Request httpRequest = new Request.Builder()
                    .url(properties.getBaseUrl() + "/api/merchant-portal/merchant-access/payment-link/create")
                    .post(body)
                    .build();

            try (Response response = client.newCall(httpRequest).execute()) {
                String raw = response.body() == null ? "" : response.body().string();
                log.info("payway_create_link_http_status={}", response.code());
                log.info("payway_create_link_response={}", raw);
                return objectMapper.readValue(raw, PayWayCreatePaymentLinkResponse.class);
            }
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to create PayWay payment link", ex);
        }
    }
}