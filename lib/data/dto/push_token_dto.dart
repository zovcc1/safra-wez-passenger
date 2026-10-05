class PushTokenDto {
  final String token;
  final String platform;

  const PushTokenDto({required this.token, required this.platform});

  Map<String, dynamic> toJson() => {"token": token, "platform": platform};
}

class DeletePushTokenDto {
  final String token;

  const DeletePushTokenDto({required this.token});

  Map<String, dynamic> toJson() => {"token": token};
}
