package com.lifeos.backend.place.infrastructure.persistence;

import com.lifeos.backend.place.domain.UserPlace;
import com.lifeos.backend.place.domain.UserPlaceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class UserPlaceRepositoryImpl implements UserPlaceRepository {

    private final UserPlaceJpaRepository jpaRepository;

    @Override
    public UserPlace save(UserPlace place) {
        return jpaRepository.save(place);
    }

    @Override
    public Optional<UserPlace> findById(UUID id) {
        return jpaRepository.findById(id);
    }

    @Override
    public List<UserPlace> findByUserId(UUID userId) {
        return jpaRepository.findByUserIdOrderByNameAsc(userId);
    }

    @Override
    public List<UserPlace> findByUserIdAndActiveTrue(UUID userId) {
        return jpaRepository.findByUserIdAndActiveTrueOrderByNameAsc(userId);
    }

    @Override
    public void deleteById(UUID id) {
        jpaRepository.deleteById(id);
    }
}