package com.lifeos.backend.place.infrastructure.persistence;

import com.lifeos.backend.place.domain.UserPlace;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface UserPlaceJpaRepository extends JpaRepository<UserPlace, UUID> {

    List<UserPlace> findByUserIdOrderByNameAsc(UUID userId);

    List<UserPlace> findByUserIdAndActiveTrueOrderByNameAsc(UUID userId);
}