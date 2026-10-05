import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:safraa_passenger_app/data/dto/login_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/core/services/push_notification_service.dart';
import 'package:safraa_passenger_app/data/dto/push_token_dto.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class LoginPageController extends GetxController {
  final AuthRepo authRepo = Get.find<AuthRepo>();
  final CacheService cacheService = Get.find<CacheService>();
  final PushNotificationService pushNotificationService =
      Get.find<PushNotificationService>();

  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  /// كود الدولة الحالي (يتغيّر عند اختيار المستخدم دولة أخرى من القائمة)
  final countryCode = "+963".obs;

  final obscurePassword = true.obs;
  final loadingState = LoadingState.idle.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args["message"] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomToasts(
          message: args["message"].toString(),
          type: CustomToastType.warning,
        ).show();
      });
    }
  }

  /// Validator بصيغة IntlPhoneField (يستقبل PhoneNumber؟ وليس String؟)
  String? phoneValidator(PhoneNumber? phone) {
    if (phone == null || phone.number.trim().isEmpty) {
      return "auth_validation_phone_required".tr;
    }
    final phoneNo = phone.number.replaceAll(" ", "");
    if (phoneNo.length != 9 || phoneNo[0] == "0") {
      return "auth_validation_phone_invalid".tr;
    }
    return null;
  }

  /// يُستدعى أثناء الكتابة عبر PhoneNumberFormatter (تنسيق العرض فقط، لا حاجة لتخزين شيء هنا)
  void onPhoneChanged(String value) {}

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty)
      return "auth_validation_password_required".tr;
    return null;
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (loadingState.value == LoadingState.loading) return;

    loadingState.value = LoadingState.loading;

    final localPhoneNumber =
        "0${phoneController.text.trim().replaceAll(' ', '')}";

    final response = await authRepo.login(
      LoginDto(
        phoneNumber: localPhoneNumber,
        password: passwordController.text,
        deviceName: "${Platform.operatingSystem} device",
      ),
    );

    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      final message = response.getErrorMessage();
      // لا يوجد كود مميّز لحالة "هاتف غير موثّق" ضمن 403 — الإشارة الوحيدة
      // المتاحة هي نص الرسالة، لذا نطابق كلمة verify/تفعيل كإشارة احتمالية
      // قبل الرجوع لعرضها كرسالة عامة تحت الحقول.
      final looksLikeUnverifiedPhone = message.toLowerCase().contains("verif");
      if (looksLikeUnverifiedPhone) {
        await cacheService.storePendingOtpPhone(localPhoneNumber);
        Get.offAllNamed(
          AppRoutes.verifyOtpRoute,
          arguments: {"phoneNumber": localPhoneNumber, "fromRegister": false},
        );
        return;
      }
      CustomToasts(message: message, type: CustomToastType.error).show();
      return;
    }

    final data = response.data!;
    await cacheService.storeSession(
      token: data.token,
      refreshToken: data.refreshToken,
      expiresIn: data.expiresIn,
    );
    await cacheService.storeUser(data.user);

    await _registerPushTokenSilently();

    loadingState.value = LoadingState.doneWithData;
    Get.offAllNamed(AppRoutes.mainRoute);
  }

  Future<void> _registerPushTokenSilently() async {
    final deviceToken = await pushNotificationService.getDeviceToken();
    if (deviceToken == null) return;
    final response = await authRepo.registerPushToken(
      PushTokenDto(
        token: deviceToken,
        platform: pushNotificationService.platformName,
      ),
    );
    if (response.success) {
      await cacheService.storeLastPushToken(deviceToken);
    }
  }

  Future<void> continueAsGuest() async {
    await cacheService.setGuestMode(true);
    Get.offAllNamed(AppRoutes.mainRoute);
  }

  void goToRegister() => Get.toNamed(AppRoutes.registerRoute);

  void goToForgotPassword() => Get.toNamed(AppRoutes.forgotPasswordRoute);

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
