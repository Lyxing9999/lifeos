//package com.lifeos.backend.place.application;
//
//import com.lifeos.backend.common.exception.NotFoundException;
//import com.lifeos.backend.place.api.request.CreateUserPlaceRequest;
//import com.lifeos.backend.place.api.request.UpdateUserPlaceRequest;
//import com.lifeos.backend.place.api.response.UserPlaceResponse;
//import com.lifeos.backend.place.domain.UserPlace;
//import com.lifeos.backend.place.domain.UserPlaceRepository;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.stereotype.Service;
//
//import java.util.List;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//@Slf4j
//public class UserPlaceService {
//
//    private final UserPlaceRepository repository;
//    private final UserPlaceMapper mapper;
//
//    public UserPlaceResponse create(CreateUserPlaceRequest request) {
//        validateCreate(request);
//
//        UserPlace place = mapper.toEntity(request);
//        UserPlace saved = repository.save(place);
//
//        log.info("user_place_created userId={} placeId={} name={}",
//                saved.getUserId(), saved.getId(), saved.getName());
//
//        return mapper.toResponse(saved);
//    }
//
//    public UserPlaceResponse update(UUID placeId, UpdateUserPlaceRequest request) {
//        UserPlace place = repository.findById(placeId)
//                .orElseThrow(() -> new NotFoundException("User place not found"));
//
//        if (request.getName() != null) place.setName(request.getName());
//        if (request.getPlaceType() != null) place.setPlaceType(request.getPlaceType());
//        if (request.getLatitude() != null) place.setLatitude(request.getLatitude());
//        if (request.getLongitude() != null) place.setLongitude(request.getLongitude());
//        if (request.getMatchRadiusMeters() != null) place.setMatchRadiusMeters(request.getMatchRadiusMeters());
//        if (request.getActive() != null) place.setActive(request.getActive());
//
//        UserPlace saved = repository.save(place);
//
//        log.info("user_place_updated userId={} placeId={} name={}",
//                saved.getUserId(), saved.getId(), saved.getName());
//
//        return mapper.toResponse(saved);
//    }
//
//    public UserPlaceResponse getById(UUID placeId) {
//        UserPlace place = repository.findById(placeId)
//                .orElseThrow(() -> new NotFoundException("User place not found"));
//        return mapper.toResponse(place);
//    }
//
//    public List<UserPlaceResponse> getByUser(UUID userId) {
//        return repository.findByUserId(userId).stream()
//                .map(mapper::toResponse)
//                .toList();
//    }
//
//    public void delete(UUID placeId) {
//        repository.deleteById(placeId);
//        log.info("user_place_deleted placeId={}", placeId);
//    }
//
//    private void validateCreate(CreateUserPlaceRequest request) {
//        if (request == null || request.getUserId() == null) {
//            throw new IllegalArgumentException("userId is required");
//        }
//        if (request.getName() == null || request.getName().isBlank()) {
//            throw new IllegalArgumentException("name is required");
//        }
//        if (request.getPlaceType() == null || request.getPlaceType().isBlank()) {
//            throw new IllegalArgumentException("placeType is required");
//        }
//        if (request.getLatitude() == null || request.getLongitude() == null) {
//            throw new IllegalArgumentException("latitude and longitude are required");
//        }
//    }
//}