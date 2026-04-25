package com.lifeos.backend.financial.infrastructure.provider.payway.log;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PayWayCallbackLogRepository extends JpaRepository<PayWayCallbackLog, UUID> {
    List<PayWayCallbackLog> findByUserIdOrderByCreatedAtDesc(UUID userId);
}