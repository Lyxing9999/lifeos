package com.lifeos.backend.financial.infrastructure.provider.payway.log;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "payway_callback_logs")
@Getter
@Setter
public class PayWayCallbackLog extends BaseEntity {
    private UUID userId;
    private String transactionId;
    private String merchantRefNo;

    @Column(columnDefinition = "TEXT")
    private String rawPayloadJson;

    private Boolean processed;

    @Column(columnDefinition = "TEXT")
    private String processingError;
}