import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/core/services/push_notification_service.dart';
import 'package:safraa_passenger_app/data/dto/push_token_dto.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class SplashPageController extends GetxController {
  final CacheService cacheService = Get.find<CacheService>();
  final AuthRepo authRepo = Get.find<AuthRepo>();
  final PushNotificationService pushNotificationService =
      Get.find<PushNotificationService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!cacheService.isLoggedIn()) {
      if (cacheService.isGuestMode()) {
        Get.offAllNamed(AppRoutes.mainRoute);
      } else if (cacheService.hasSeenOnboarding()) {
        Get.offAllNamed(AppRoutes.loginRoute);
      } else {
        Get.offAllNamed(AppRoutes.onboardingRoute);
      }
      return;
    }

    if (cacheService.isTokenNearExpiry()) {
      final refreshToken = await cacheService.getUserRefreshToken();
      final response = await authRepo.refresh(refreshToken);
      if (!response.success) {
        await cacheService.clearAll();
        CustomToasts(
          message: response.getErrorMessage(),
          type: CustomToastType.error,
        ).show();
        Get.offAllNamed(AppRoutes.loginRoute);
        return;
      }
      await cacheService.storeSession(
        token: response.data!.token,
        refreshToken: response.data!.refreshToken,
        expiresIn: response.data!.expiresIn,
      );
    }

    final meResponse = await authRepo.me();
    if (!meResponse.success) {
      // فشل شبكة عابر لا يُخرج المستخدم؛ 401 يُدار تلقائيًا عبر
      // TokenRefreshInterceptor (يمسح الجلسة ويوجّه لتسجيل الدخول بنفسه).
      Get.offAllNamed(AppRoutes.mainRoute);
      return;
    }

    final user = meResponse.data!;
    await cacheService.storeUser(user);

    if (user.isSuspended) {
      await cacheService.clearAll();
      CustomToasts(
        message: meResponse.successMessage ?? "splash_account_suspended".tr,
        type: CustomToastType.error,
      ).show();
      Get.offAllNamed(AppRoutes.loginRoute);
      return;
    }

    if (!user.isPhoneVerified) {
      Get.offAllNamed(
        AppRoutes.verifyOtpRoute,
        arguments: {"phoneNumber": user.phoneNumber, "fromSplash": true},
      );
      return;
    }

    await _registerPushTokenSilently();
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
}
