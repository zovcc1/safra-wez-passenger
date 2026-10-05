class VerifyOtpDto {
  final String phoneNumber;
  final String code;

  const VerifyOtpDto({required this.phoneNumber, required this.code});

  Map<String, dynamic> toJson() => {"phone_number": phoneNumber, "code": code};
}
