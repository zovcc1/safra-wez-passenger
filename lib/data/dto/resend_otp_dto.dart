class ResendOtpDto {
  final String phoneNumber;

  const ResendOtpDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {"phone_number": phoneNumber};
}
