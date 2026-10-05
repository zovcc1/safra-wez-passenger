class RefreshResponseModel {
  final String token;
  final String refreshToken;
  final int? expiresIn;

  const RefreshResponseModel({
    required this.token,
    required this.refreshToken,
    this.expiresIn,
  });

  factory RefreshResponseModel.fromJson(Map<String, dynamic> json) =>
      RefreshResponseModel(
        token: json["token"] ?? "",
        refreshToken: json["refresh_token"] ?? "",
        expiresIn: json["expires_in"] as int?,
      );
}
