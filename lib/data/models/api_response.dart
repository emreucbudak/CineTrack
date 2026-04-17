class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorCode;
  final String? errorMessage;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    return PaginatedResult(
      items: (json['items'] as List?)
              ?.map((e) => fromItem(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
