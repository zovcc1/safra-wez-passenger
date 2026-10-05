class CursorPaginatedResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  CursorPaginatedResponse({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  factory CursorPaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) => CursorPaginatedResponse(
    items: List<Map<String, dynamic>>.from(
      json["items"] ?? const [],
    ).map(itemParser).toList(),
    nextCursor: json["next_cursor"],
    hasMore: json["has_more"] ?? false,
  );
}
