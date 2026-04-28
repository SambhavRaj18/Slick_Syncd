class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(success: false, message: message, statusCode: statusCode);
  }

  bool get hasData => data != null;

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
}
