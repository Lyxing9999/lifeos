import '../../../core/enums/loading_status.dart';
import '../domain/model/place.dart';

const _unset = Object();

class PlaceState {
  final LoadingStatus status;
  final List<Place> items;
  final Place? selectedItem;
  final String? errorMessage;
  final String? successMessage;

  const PlaceState({
    required this.status,
    required this.items,
    required this.selectedItem,
    required this.errorMessage,
    required this.successMessage,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory PlaceState.initial() {
    return const PlaceState(
      status: LoadingStatus.idle,
      items: [],
      selectedItem: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  PlaceState copyWith({
    LoadingStatus? status,
    List<Place>? items,
    Object? selectedItem = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return PlaceState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedItem: identical(selectedItem, _unset)
          ? this.selectedItem
          : selectedItem as Place?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}
