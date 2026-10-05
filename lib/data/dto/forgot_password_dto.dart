class ForgotPasswordDto {
  final String phoneNumber;

  const ForgotPasswordDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {"phone_number": phoneNumber};
}
