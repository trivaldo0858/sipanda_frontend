// lib/core/utils/api_response.dart

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  const ApiResponse._({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message}) => ApiResponse._(
        success: true,
        data: data,
        message: message,
      );

  factory ApiResponse.error(String error) => ApiResponse._(
        success: false,
        error: error,
      );

  bool get isSuccess => success && data != null;
}