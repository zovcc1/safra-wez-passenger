class ResetPasswordDto {
  final String phoneNumber;
  final String code;
  final String password;

  const ResetPasswordDto({
    required this.phoneNumber,
    required this.code,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "phone_number": phoneNumber,
    "code": code,
    "password": password,
  };
}
