class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final DateTime timestamp;
  final List<ApiError>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    required this.timestamp,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      meta: json['meta'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      errors: json['errors'] != null
          ? (json['errors'] as List).map((e) => ApiError.fromJson(e)).toList()
          : null,
    );
  }

  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get hasMeta => meta != null;

  // Pagination helpers
  int? get currentPage => meta?['pagination']?['currentPage'];
  int? get totalPages => meta?['pagination']?['totalPages'];
  int? get totalItems => meta?['pagination']?['totalItems'];
  bool get hasNextPage => meta?['pagination']?['hasNextPage'] ?? false;
  bool get hasPrevPage => meta?['pagination']?['hasPrevPage'] ?? false;
}

class ApiError {
  final String field;
  final String message;
  final dynamic value;

  ApiError({required this.field, required this.message, this.value});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      value: json['value'],
    );
  }
}

// Success Response Helper
class SuccessResponse<T> extends ApiResponse<T> {
  SuccessResponse({
    required String message,
    T? data,
    Map<String, dynamic>? meta,
  }) : super(
         success: true,
         message: message,
         data: data,
         meta: meta,
         timestamp: DateTime.now(),
       );
}

// Error Response Helper
class ErrorResponse<T> extends ApiResponse<T> {
  ErrorResponse({required String message, List<ApiError>? errors})
    : super(
        success: false,
        message: message,
        timestamp: DateTime.now(),
        errors: errors,
      );
}
