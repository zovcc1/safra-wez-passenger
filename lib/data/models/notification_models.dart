class NotificationItemModel {
  final int notificationId;
  final String type;
  final String? title;
  final String message;
  bool isRead;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  NotificationItemModel({
    required this.notificationId,
    required this.type,
    this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    required this.data,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) =>
      NotificationItemModel(
        notificationId: json["notification_id"] ?? 0,
        type: json["type"]?.toString() ?? "",
        title: json["title"]?.toString(),
        message: json["message"]?.toString() ?? "",
        isRead: json["is_read"] ?? false,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"].toString())
            : null,
        data: json["data"] is Map
            ? Map<String, dynamic>.from(json["data"])
            : <String, dynamic>{},
      );
}

class NotificationPreferenceModel {
  /// transactional | reminder | promotional | service
  final String category;
  bool enabled;
  final bool isOptional;

  NotificationPreferenceModel({
    required this.category,
    required this.enabled,
    required this.isOptional,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) =>
      NotificationPreferenceModel(
        category: json["category"]?.toString() ?? "",
        enabled: json["enabled"] ?? true,
        isOptional: json["is_optional"] ?? false,
      );
}
