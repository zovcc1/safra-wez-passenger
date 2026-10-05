import 'package:safraa_passenger_app/data/models/passenger_user_model.dart';

class LoginResponseModel {
  final String token;
  final String refreshToken;
  final int? expiresIn;
  final PassengerUserModel user;

  const LoginResponseModel({
    required this.token,
    required this.refreshToken,
    this.expiresIn,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        token: json["token"] ?? "",
        refreshToken: json["refresh_token"] ?? "",
        expiresIn: json["expires_in"] as int?,
        user: PassengerUserModel.fromJson(json["user"] ?? {}),
      );
}
