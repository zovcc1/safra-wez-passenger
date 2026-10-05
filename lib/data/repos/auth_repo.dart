import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/dto/change_password_dto.dart';
import 'package:safraa_passenger_app/data/dto/forgot_password_dto.dart';
import 'package:safraa_passenger_app/data/dto/login_dto.dart';
import 'package:safraa_passenger_app/data/dto/push_token_dto.dart';
import 'package:safraa_passenger_app/data/dto/register_dto.dart';
import 'package:safraa_passenger_app/data/dto/resend_otp_dto.dart';
import 'package:safraa_passenger_app/data/dto/reset_password_dto.dart';
import 'package:safraa_passenger_app/data/dto/verify_otp_dto.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/login_response_model.dart';
import 'package:safraa_passenger_app/data/models/passenger_user_model.dart';
import 'package:safraa_passenger_app/data/models/refresh_response_model.dart';

class AuthRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  Future<AppResponse<LoginResponseModel>> login(LoginDto dto) => _call(
    url: Api.login,
    params: dto.toJson(),
    requiredToken: false,
    parse: (data) => LoginResponseModel.fromJson(data),
  );

  /// يُستخدم من Splash للتحديث الاستباقي عندما يكون التوكن قريبًا من
  /// الانتهاء (راجع CacheService.isTokenNearExpiry). الـ refresh التفاعلي
  /// عند 401 يُدار بشكل منفصل داخل TokenRefreshInterceptor.
  Future<AppResponse<RefreshResponseModel>> refresh(String refreshToken) =>
      _call(
        url: Api.refresh,
        requiredToken: false,
        additionalHeaders: {"Authorization": "Bearer $refreshToken"},
        parse: (data) => RefreshResponseModel.fromJson(data),
      );

  Future<AppResponse<PassengerUserModel>> register(RegisterDto dto) => _call(
    url: Api.register,
    params: dto.toJson(),
    requiredToken: false,
    parse: (data) => PassengerUserModel.fromJson(data),
  );

  Future<AppResponse<PassengerUserModel>> verifyOtp(VerifyOtpDto dto) => _call(
    url: Api.verifyOtp,
    params: dto.toJson(),
    requiredToken: false,
    parse: (data) => PassengerUserModel.fromJson(data),
  );

  Future<AppResponse<void>> resendOtp(ResendOtpDto dto) => _call(
    url: Api.resendOtp,
    params: dto.toJson(),
    requiredToken: false,
    parse: (_) {},
  );

  Future<AppResponse<void>> forgotPassword(ForgotPasswordDto dto) => _call(
    url: Api.forgotPassword,
    params: dto.toJson(),
    requiredToken: false,
    parse: (_) {},
  );

  Future<AppResponse<void>> resetPassword(ResetPasswordDto dto) => _call(
    url: Api.resetPassword,
    params: dto.toJson(),
    requiredToken: false,
    parse: (_) {},
  );

  Future<AppResponse<void>> changePassword(ChangePasswordDto dto) => _call(
    url: Api.changePassword,
    params: dto.toJson(),
    requiredToken: true,
    parse: (_) {},
  );

  Future<AppResponse<void>> logout() => _call(
    url: Api.logout,
    method: Method.post,
    requiredToken: true,
    parse: (_) {},
  );

  Future<AppResponse<void>> logoutAll() => _call(
    url: Api.logoutAll,
    method: Method.post,
    requiredToken: true,
    parse: (_) {},
  );

  Future<AppResponse<PassengerUserModel>> me() => _call(
    url: Api.me,
    method: Method.get,
    requiredToken: true,
    parse: (data) => PassengerUserModel.fromJson(data),
  );

  Future<AppResponse<void>> registerPushToken(PushTokenDto dto) => _call(
    url: Api.pushToken,
    method: Method.put,
    params: dto.toJson(),
    requiredToken: true,
    parse: (_) {},
  );

  Future<AppResponse<void>> deletePushToken(DeletePushTokenDto dto) => _call(
    url: Api.pushToken,
    method: Method.delete,
    params: dto.toJson(),
    requiredToken: true,
    parse: (_) {},
  );

  /// نداء API موحّد يطبّق نمط {success, message, data, errors} على كل شاشات
  /// Auth بنفس الطريقة (راجع AppResponse/extractErrorMessage/extractFieldErrors).
  Future<AppResponse<T>> _call<T>({
    required String url,
    Method method = Method.post,
    Map<String, dynamic>? params,
    required bool requiredToken,
    Map<String, dynamic>? additionalHeaders,
    required T Function(Map<String, dynamic> data) parse,
  }) async {
    AppResponse<T> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: url,
        method: method,
        params: params == null ? null : jsonEncode(params),
        requiredToken: requiredToken,
        additionalHeaders: additionalHeaders,
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = parse(json["data"] ?? {});
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
        appResponse.fieldErrors = AppResponse.extractFieldErrors(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
      // 422/403 وغيرها من الأخطاء غير 2xx تصل هنا كـ DioException (Dio يرمي
      // استثناءً لأي استجابة غير 2xx)، فلا تمر أبدًا بفرع json["success"]
      // أعلاه — نستخرج fieldErrors من جسم الاستجابة هنا كي لا تضيع رسائل
      // الحقول (راجع نفس الملاحظة في error_handler.dart).
      if (e is DioException && e.response?.data is Map) {
        appResponse.fieldErrors = AppResponse.extractFieldErrors(
          Map<String, dynamic>.from(e.response!.data),
        );
      }
    }
    return appResponse;
  }
}
