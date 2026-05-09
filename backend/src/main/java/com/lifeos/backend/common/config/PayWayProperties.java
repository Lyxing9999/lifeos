package com.lifeos.backend.common.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "lifeos.payway")
public class PayWayProperties {

    private boolean enabled = false;
    private String baseUrl;
    private String merchantId;
    private String apiKey;
    private String rsaPublicKey;
    private String timezone = "Asia/Phnom_Penh";

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }

    public String getBaseUrl() { return baseUrl; }
    public void setBaseUrl(String baseUrl) { this.baseUrl = baseUrl; }

    public String getMerchantId() { return merchantId; }
    public void setMerchantId(String merchantId) { this.merchantId = merchantId; }

    public String getApiKey() { return apiKey; }
    public void setApiKey(String apiKey) { this.apiKey = apiKey; }

    public String getRsaPublicKey() { return rsaPublicKey; }
    public void setRsaPublicKey(String rsaPublicKey) { this.rsaPublicKey = rsaPublicKey; }

    public String getTimezone() { return timezone; }
    public void setTimezone(String timezone) { this.timezone = timezone; }
}