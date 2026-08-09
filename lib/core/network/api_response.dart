class ApiResponse<T> {
  const ApiResponse({this.data, this.message, this.meta});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json.containsKey('data') ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      meta: json['meta'] is Map<String, dynamic>
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  final T? data;
  final String? message;
  final PaginationMeta? meta;

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return <String, dynamic>{
      if (data != null) 'data': toJsonT(data as T),
      if (message != null) 'message': message,
      if (meta != null) 'meta': meta!.toJson(),
    };
  }
}

class PaginationMeta {
  const PaginationMeta({this.page, this.pageSize, this.total, this.totalPages});

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: _asInt(json['page']),
      pageSize: _asInt(json['page_size'] ?? json['pageSize']),
      total: _asInt(json['total']),
      totalPages: _asInt(json['total_pages'] ?? json['totalPages']),
    );
  }

  final int? page;
  final int? pageSize;
  final int? total;
  final int? totalPages;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (page != null) 'page': page,
      if (pageSize != null) 'page_size': pageSize,
      if (total != null) 'total': total,
      if (totalPages != null) 'total_pages': totalPages,
    };
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}