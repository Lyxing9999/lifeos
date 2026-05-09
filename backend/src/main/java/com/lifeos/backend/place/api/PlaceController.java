//package com.lifeos.backend.place.api;
//
//import com.lifeos.backend.common.response.ApiResponse;
//import com.lifeos.backend.place.api.request.CreateUserPlaceRequest;
//import com.lifeos.backend.place.api.request.UpdateUserPlaceRequest;
//import com.lifeos.backend.place.api.response.PlaceMatchResponse;
//import com.lifeos.backend.place.api.response.UserPlaceResponse;
//import com.lifeos.backend.place.application.PlaceMatchingResult;
//import com.lifeos.backend.place.application.PlaceMatchingService;
//import com.lifeos.backend.place.application.UserPlaceService;
//import lombok.RequiredArgsConstructor;
//import org.springframework.web.bind.annotation.*;
//
//import java.util.List;
//import java.util.UUID;
//
//@RestController
//@RequestMapping("/api/v1/places")
//@RequiredArgsConstructor
//public class PlaceController {
//
//    private final UserPlaceService userPlaceService;
//    private final PlaceMatchingService placeMatchingService;
//
//    @PostMapping
//    public ApiResponse<UserPlaceResponse> create(@RequestBody CreateUserPlaceRequest request) {
//        return ApiResponse.success(userPlaceService.create(request), "Place created");
//    }
//
//    @PatchMapping("/{placeId}")
//    public ApiResponse<UserPlaceResponse> update(
//            @PathVariable UUID placeId,
//            @RequestBody UpdateUserPlaceRequest request
//    ) {
//        return ApiResponse.success(userPlaceService.update(placeId, request), "Place updated");
//    }
//
//    @GetMapping("/{placeId}")
//    public ApiResponse<UserPlaceResponse> getById(@PathVariable UUID placeId) {
//        return ApiResponse.success(userPlaceService.getById(placeId));
//    }
//
//    @GetMapping("/user/{userId}")
//    public ApiResponse<List<UserPlaceResponse>> getByUser(@PathVariable UUID userId) {
//        return ApiResponse.success(userPlaceService.getByUser(userId));
//    }
//
//    @DeleteMapping("/{placeId}")
//    public ApiResponse<Void> delete(@PathVariable UUID placeId) {
//        userPlaceService.delete(placeId);
//        return ApiResponse.success(null, "Place deleted");
//    }
//
//    @GetMapping("/match")
//    public ApiResponse<PlaceMatchResponse> match(
//            @RequestParam UUID userId,
//            @RequestParam double latitude,
//            @RequestParam double longitude,
//            @RequestParam(defaultValue = "15") long durationMinutes
//    ) {
//        PlaceMatchingResult result = placeMatchingService.match(userId, latitude, longitude, durationMinutes);
//
//        return ApiResponse.success(
//                PlaceMatchResponse.builder()
//                        .placeName(result.getPlaceName())
//                        .placeType(result.getPlaceType())
//                        .source(result.getSource())
//                        .confidence(result.getConfidence())
//                        .build()
//        );
//    }
//}