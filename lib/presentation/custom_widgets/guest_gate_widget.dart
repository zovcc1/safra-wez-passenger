import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/core/services/theme_controller.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

/// بديل أي صفحة تحتاج توكن عندما يكون المستخدم ضيفًا.
class GuestGateWidget extends StatelessWidget {
  const GuestGateWidget({
    super.key,
    this.icon = Icons.lock_outline_rounded,
    this.titleKey = "guest_gate_title",
    this.subtitleKey = "guest_gate_subtitle",
    this.showSettings = false,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;

  /// يعرض مفاتيح اللغة والمود (تبويب "حسابي" للضيف).
  final bool showSettings;

  /// الدخول/التسجيل يمسحان المكدّس؛ نجاح الدخول يعيد المستخدم للرئيسية.
  static void goToLogin() => Get.offAllNamed(AppRoutes.loginRoute);

  static void goToRegister() => Get.offAllNamed(AppRoutes.registerRoute);

  /// Bottom sheet عند محاولة الضيف تنفيذ إجراء يحتاج حسابًا (حجز، إشعارات...).
  static void promptLogin() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppPadding.p24),
        decoration: BoxDecoration(
          color: ColorManager.colorWhite,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppPadding.p20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _IconBadge(icon: Icons.lock_outline_rounded, size: 64),
              const SizedBox(height: AppPadding.p16),
              Text(
                "guest_gate_title".tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              const SizedBox(height: AppPadding.p8),
              Text(
                "guest_gate_subtitle".tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: ColorManager.colorDoveGray600,
                ),
              ),
              const SizedBox(height: AppPadding.p20),
              const _AuthButtons(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppPadding.p24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconBadge(icon: icon, size: 96),
                const SizedBox(height: AppPadding.p20),
                Text(
                  titleKey.tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
                const SizedBox(height: AppPadding.p8),
                Text(
                  subtitleKey.tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: ColorManager.colorDoveGray600,
                  ),
                ),
                const SizedBox(height: AppPadding.p24),
                const _AuthButtons(),
                if (showSettings) ...[
                  const SizedBox(height: AppPadding.p24),
                  const _GuestSettings(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorManager.colorPrimary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.45, color: ColorManager.colorPrimary),
    );
  }
}

class _AuthButtons extends StatelessWidget {
  const _AuthButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          text: "auth_login_button".tr,
          radius: 14,
          minHeight: 52,
          onPressed: GuestGateWidget.goToLogin,
        ),
        const SizedBox(height: AppPadding.p12),
        AppButton(
          text: "auth_create_account_button".tr,
          radius: 14,
          minHeight: 52,
          backgroundColor: ColorManager.colorWhite,
          fontColor: ColorManager.colorPrimary,
          border: Border.all(color: ColorManager.colorPrimary),
          onPressed: GuestGateWidget.goToRegister,
        ),
      ],
    );
  }
}

class _GuestSettings extends StatelessWidget {
  const _GuestSettings();

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(AppPadding.p16),
      ),
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              secondary: Icon(
                Icons.dark_mode_outlined,
                color: ColorManager.colorPrimary,
              ),
              title: Text("profile_dark_mode".tr),
              value: theme.isDarkMode.value,
              onChanged: (_) => theme.toggleTheme(),
            ),
          ),
          Divider(
            height: 1,
            color: ColorManager.colorGrey6.withValues(alpha: 0.3),
          ),
          ListTile(
            leading: Icon(Icons.language, color: ColorManager.colorPrimary),
            title: Text("profile_language".tr),
            trailing: Text(
              AppTranslations.isArabic
                  ? "profile_lang_english".tr
                  : "profile_lang_arabic".tr,
              style: TextStyle(color: ColorManager.colorPrimary),
            ),
            onTap: () => AppTranslations.changeLocale(
              AppTranslations.isArabic ? 'en' : 'ar',
            ),
          ),
        ],
      ),
    );
  }
}
