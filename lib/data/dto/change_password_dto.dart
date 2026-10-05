class ChangePasswordDto {
  final String currentPassword;
  final String password;

  const ChangePasswordDto({
    required this.currentPassword,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "current_password": currentPassword,
    "password": password,
  };
}
