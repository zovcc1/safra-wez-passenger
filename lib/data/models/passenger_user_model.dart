class PassengerUserModel {
  final int userId;
  final String phoneNumber;
  final String? nationalId;
  final String fullName;
  final String? photoUrl;
  final DateTime? phoneVerifiedAt;
  final String accountStatus;
  final bool mustChangePassword;
  final int noShowCount;
  final DateTime? createdAt;
  final List<String> identities;
  final List<String> roles;
  final List<String> permissions;

  const PassengerUserModel({
    required this.userId,
    required this.phoneNumber,
    this.nationalId,
    required this.fullName,
    this.photoUrl,
    this.phoneVerifiedAt,
    required this.accountStatus,
    required this.mustChangePassword,
    required this.noShowCount,
    this.createdAt,
    required this.identities,
    required this.roles,
    required this.permissions,
  });

  bool get isPhoneVerified => phoneVerifiedAt != null;

  bool get isSuspended => accountStatus != "active";

  factory PassengerUserModel.fromJson(Map<String, dynamic> json) =>
      PassengerUserModel(
        userId: json["user_id"],
        phoneNumber: json["phone_number"] ?? "",
        nationalId: json["national_id"],
        fullName: json["full_name"] ?? "",
        photoUrl: json["photo_url"],
        phoneVerifiedAt: json["phone_verified_at"] != null
            ? DateTime.tryParse(json["phone_verified_at"])
            : null,
        accountStatus: json["account_status"] ?? "active",
        mustChangePassword: json["must_change_password"] ?? false,
        noShowCount: json["no_show_count"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        identities: List<String>.from(json["identities"] ?? const []),
        roles: List<String>.from(json["roles"] ?? const []),
        permissions: List<String>.from(json["permissions"] ?? const []),
      );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "phone_number": phoneNumber,
    "national_id": nationalId,
    "full_name": fullName,
    "photo_url": photoUrl,
    "phone_verified_at": phoneVerifiedAt?.toIso8601String(),
    "account_status": accountStatus,
    "must_change_password": mustChangePassword,
    "no_show_count": noShowCount,
    "created_at": createdAt?.toIso8601String(),
    "identities": identities,
    "roles": roles,
    "permissions": permissions,
  };
}
