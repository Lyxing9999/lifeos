package com.lifeos.backend.place.domain;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserPlaceRepository {

    UserPlace save(UserPlace place);

    Optional<UserPlace> findById(UUID id);

    List<UserPlace> findByUserId(UUID userId);

    List<UserPlace> findByUserIdAndActiveTrue(UUID userId);

    void deleteById(UUID id);
}