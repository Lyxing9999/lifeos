package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

import java.util.HashMap;
import java.util.Map;

@Getter
@Setter
public class PayWayCallbackPayload {

    @JsonProperty("tran_id")
    private String tranId;

    private Integer status;

    @JsonProperty("merchant_ref_no")
    private String merchantRefNo;

    private String apv;

    private final Map<String, Object> raw = new HashMap<>();

    @JsonAnySetter
    public void captureUnknown(String key, Object value) {
        raw.put(key, value);
    }
}