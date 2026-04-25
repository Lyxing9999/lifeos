typedef JsonMap = Map<String, dynamic>;

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  const ApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ApiResponse.fromJson(
    JsonMap json,
    T? Function(dynamic rawData) parser,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: parser(json['data']),
      message: json['message'] as String? ?? 'Success',
    );
  }
}
