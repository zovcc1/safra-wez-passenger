class LoginDto {
  final String phoneNumber;
  final String password;
  final String deviceName;

  const LoginDto({
    required this.phoneNumber,
    required this.password,
    required this.deviceName,
  });

  Map<String, dynamic> toJson() => {
    "phone_number": phoneNumber,
    "password": password,
    "app_context": "passenger",
    "device_name": deviceName,
  };
}
