class RegisterDto {
  final String phoneNumber;
  final String nationalId;
  final String fullName;
  final String password;

  const RegisterDto({
    required this.phoneNumber,
    required this.nationalId,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "phone_number": phoneNumber,
    "national_id": nationalId,
    "full_name": fullName,
    "password": password,
  };
}
