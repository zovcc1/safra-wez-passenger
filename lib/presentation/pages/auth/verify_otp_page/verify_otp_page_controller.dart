import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/data/dto/resend_otp_dto.dart';
import 'package:safraa_passenger_app/data/dto/verify_otp_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

const int kOtpResendCooldownSeconds = 60;
const int kOtpMaxAttempts = 3;

class VerifyOtpPageController extends GetxController {
  final AuthRepo authRepo = Get.find<AuthRepo>();
  final CacheService cacheService = Get.find<CacheService>();

  late final String phoneNumber;
  late final bool fromRegister;
  late final bool fromSplash;

  final codeController = TextEditingController();
  final loadingState = LoadingState.idle.obs;
  final remainingAttempts = kOtpMaxAttempts.obs;
  final resendCooldown = 0.obs;
  final resending = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    phoneNumber =
        (args is Map ? args["phoneNumber"] as String? : null) ??
        cacheService.getPendingOtpPhone() ??
        "";
    fromRegister = args is Map ? (args["fromRegister"] == true) : false;
    fromSplash = args is Map ? (args["fromSplash"] == true) : false;
    cacheService.storePendingOtpPhone(phoneNumber);
    _startCooldown();
  }

  void _startCooldown() {
    resendCooldown.value = kOtpResendCooldownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value <= 1) {
        resendCooldown.value = 0;
        timer.cancel();
      } else {
        resendCooldown.value--;
      }
    });
  }

  Future<void> verify(String code) async {
    if (loadingState.value == LoadingState.loading) return;
    if (remainingAttempts.value <= 0) return;

    loadingState.value = LoadingState.loading;

    final response = await authRepo.verifyOtp(
      VerifyOtpDto(phoneNumber: phoneNumber, code: code),
    );

    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      remainingAttempts.value = remainingAttempts.value - 1;
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    loadingState.value = LoadingState.doneWithData;
    await cacheService.clearPendingOtpPhone();

    if (fromSplash) {
      Get.offAllNamed(AppRoutes.mainRoute);
    } else {
      Get.offAllNamed(AppRoutes.loginRoute);
    }
  }

  Future<void> resend() async {
    if (resendCooldown.value > 0 || resending.value) return;
    resending.value = true;

    final response = await authRepo.resendOtp(
      ResendOtpDto(phoneNumber: phoneNumber),
    );

    resending.value = false;

    if (response.success) {
      remainingAttempts.value = kOtpMaxAttempts;
      _startCooldown();
      CustomToasts(
        message: response.successMessage ?? "verify_otp_resend_success".tr,
        type: CustomToastType.success,
      ).show();
    } else {
      // 429 يحمل الثواني المتبقية ضمن الرسالة — نعرضها كما هي ونعيد ضبط
      // العداد من جديد بدل تحليلها لاستخراج الرقم.
      _startCooldown();
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.warning,
      ).show();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    codeController.dispose();
    super.onClose();
  }
}
