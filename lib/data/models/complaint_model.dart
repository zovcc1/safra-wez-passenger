/// حالات الشكوى. أي قيمة غير معروفة (حالة مستقبلية) تصبح [unknown] ولا تكرّش
/// الشاشة: نعرض النص الخام بـ chip محايد وتبقى المحادثة شغالة.
enum ComplaintStatus {
  open,
  inProgress,
  awaitingPassenger,
  resolved,
  rejected,
  unknown;

  static ComplaintStatus parse(String? raw) => switch (raw) {
    "open" => open,
    "in_progress" => inProgress,
    "awaiting_passenger" => awaitingPassenger,
    "resolved" => resolved,
    "rejected" => rejected,
    _ => unknown,
  };
}

class ComplaintModel {
  final int complaintId;
  final int? bookingId;
  final String category;
  final String description;

  /// القيمة الخام كما ترجع من الـ API (تُعرض كما هي عند [ComplaintStatus.unknown]).
  final String status;
  final ComplaintStatus statusType;

  /// فقط بحالة resolved.
  final String? resolution;

  /// فقط بحالة rejected. غايب من الباك القديم يعني null.
  final String? rejectionReason;
  final DateTime? createdAt;

  /// فقط بحالة resolved، و null بحالة rejected — لا تستعمله كمؤشر إغلاق.
  final DateTime? resolvedAt;

  ComplaintModel({
    required this.complaintId,
    this.bookingId,
    required this.category,
    required this.description,
    required this.status,
    this.resolution,
    this.rejectionReason,
    this.createdAt,
    this.resolvedAt,
  }) : statusType = ComplaintStatus.parse(status);

  bool get isAwaitingPassenger =>
      statusType == ComplaintStatus.awaitingPassenger;

  /// الإغلاق = resolved أو rejected (الأدمن فقط يفتح/يسكّر، والمسافر يبقى يقدر
  /// يرد على الشكوى المغلقة).
  bool get isClosed =>
      statusType == ComplaintStatus.resolved ||
      statusType == ComplaintStatus.rejected;

  factory ComplaintModel.fromJson(Map<String, dynamic> json) => ComplaintModel(
    complaintId: json["complaint_id"] ?? 0,
    bookingId: json["booking_id"],
    category: json["category"]?.toString() ?? "",
    description: json["description"]?.toString() ?? "",
    status: json["status"]?.toString() ?? "",
    resolution: json["resolution"],
    rejectionReason: json["rejection_reason"],
    createdAt: json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : null,
    resolvedAt: json["resolved_at"] != null
        ? DateTime.tryParse(json["resolved_at"])
        : null,
  );
}

class ComplaintReplyModel {
  final int replyId;
  final String authorSide;
  final String body;
  final DateTime? createdAt;

  const ComplaintReplyModel({
    required this.replyId,
    required this.authorSide,
    required this.body,
    this.createdAt,
  });

  bool get isFromPassenger => authorSide == "passenger";

  factory ComplaintReplyModel.fromJson(Map<String, dynamic> json) =>
      ComplaintReplyModel(
        replyId: json["reply_id"] ?? 0,
        authorSide: json["author_side"]?.toString() ?? "admin",
        body: json["body"]?.toString() ?? "",
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
      );
}
