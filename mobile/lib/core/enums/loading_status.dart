enum LoadingStatus { idle, loading, saving, success, error }

extension LoadingStatusX on LoadingStatus {
  bool get isIdle => this == LoadingStatus.idle;
  bool get isLoading => this == LoadingStatus.loading;
  bool get isSaving => this == LoadingStatus.saving;
  bool get isSuccess => this == LoadingStatus.success;
  bool get isError => this == LoadingStatus.error;
  
}
