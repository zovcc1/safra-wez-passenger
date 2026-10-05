import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/core/services/push_notification_service.dart';
import 'package:safraa_passenger_app/core/services/theme_controller.dart';
import 'package:safraa_passenger_app/data/dto/push_token_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/passenger_user_model.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

/// راجع القسم 12 — لا Endpoints جديدة هنا، كلها من Auth (/auth/me،
/// change-password، logout، logout-all) وتُجمَّع بواجهة واحدة، بالإضافة
/// لمفتاحي اللغة والمود اللذين تُديرهما CacheService/ThemeController أصلًا
/// دون أي واجهة مستخدم تستدعيهما حتى الآن.
class ProfilePageController extends GetxController {
  final AuthRepo authRepo = Get.find<AuthRepo>();
  final CacheService cacheService = Get.find<CacheService>();
  final ThemeController themeController = Get.find<ThemeController>();
  final PushNotificationService pushNotificationService =
      Get.find<PushNotificationService>();

  final loadingState = LoadingState.idle.obs;
  final Rxn<PassengerUserModel> user = Rxn<PassengerUserModel>();
  final loggingOut = false.obs;

  bool get isDarkMode => themeController.isDarkMode.value;

  bool get isArabic => AppTranslations.isArabic;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loadingState.value = LoadingState.loading;
    final response = await authRepo.me();
    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      return;
    }
    user.value = response.data;
    await cacheService.storeUser(response.data!);
    loadingState.value = LoadingState.doneWithData;
  }

  Future<void> retry() => _load();

  void toggleDarkMode() => themeController.toggleTheme();

  void setLanguage(String languageCode) =>
      AppTranslations.changeLocale(languageCode);

  void goToWallet() => Get.toNamed(AppRoutes.walletRoute);

  void goToComplaints() => Get.toNamed(AppRoutes.complaintsRoute);

  void goToNotificationSettings() =>
      Get.toNamed(AppRoutes.notificationSettingsRoute);

  void goToChangePassword() => Get.toNamed(AppRoutes.changePasswordRoute);

  Future<void> logout() async {
    if (loggingOut.value) return;
    loggingOut.value = true;

    // إلغاء توكن Push أولًا (راجع القسم 12) — يُتجاهل بأمان حتى يُربط FCM
    // فعليًا (راجع PushNotificationService).
    final lastPushToken = cacheService.getLastPushToken();
    if (lastPushToken != null) {
      await authRepo.deletePushToken(DeletePushTokenDto(token: lastPushToken));
    }

    final response = await authRepo.logout();
    loggingOut.value = false;

    if (!response.success) {
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    await cacheService.clearSession();
    Get.offAllNamed(AppRoutes.loginRoute);
  }

  Future<void> logoutAll() async {
    if (loggingOut.value) return;
    loggingOut.value = true;

    final lastPushToken = cacheService.getLastPushToken();
    if (lastPushToken != null) {
      await authRepo.deletePushToken(DeletePushTokenDto(token: lastPushToken));
    }

    final response = await authRepo.logoutAll();
    loggingOut.value = false;

    if (!response.success) {
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    await cacheService.clearSession();
    Get.offAllNamed(AppRoutes.loginRoute);
  }
}
