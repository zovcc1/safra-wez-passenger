import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/user_avatar_widget.dart';
import 'package:safraa_passenger_app/presentation/pages/profile_page/profile_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class ProfilePage extends GetView<ProfilePageController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.retry,
          child: Obx(() => _body()),
        ),
      ),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle || state == LoadingState.loading) {
      return const AppPageLoader();
    }

    if (state == LoadingState.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ErrorPlaceholderWidget(title: "profile_error_title".tr),
          ),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: AppButton(
              text: "common_retry".tr,
              onPressed: controller.retry,
            ),
          ),
        ],
      );
    }

    final user = controller.user.value!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        FadeSlideIn(
          child: _CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserHeader(
                  name: user.fullName,
                  phone: user.phoneNumber,
                  photoUrl: user.photoUrl,
                  isPhoneVerified: user.isPhoneVerified,
                ),
                const SizedBox(height: AppPadding.p12),
                _AccountInfoBox(
                  nationalId: user.nationalId,
                  joinDate: DateConverter.dateToStringAR(user.createdAt),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppPadding.p8),
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: _SectionCard(
            icon: Icons.tune_outlined,
            title: "profile_section_settings".tr,
            children: [
              Obx(
                () => _SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  label: "profile_appearance".tr,
                  trailing: _SegmentedToggle(
                    options: [
                      ("light", "profile_theme_light".tr),
                      ("dark", "profile_theme_dark".tr),
                    ],
                    selectedIndex: controller.isDarkMode ? 1 : 0,
                    onChanged: (mode) {
                      if ((mode == "dark") != controller.isDarkMode) {
                        controller.toggleDarkMode();
                      }
                    },
                  ),
                ),
              ),
              _LanguageRow(
                isArabic: controller.isArabic,
                onChanged: controller.setLanguage,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPadding.p8),
        FadeSlideIn(
          delay: const Duration(milliseconds: 210),
          child: _SectionCard(
            icon: Icons.manage_accounts_outlined,
            title: "profile_section_account_actions".tr,
            children: [
              _ActionRow(
                icon: Icons.account_balance_wallet_outlined,
                label: "profile_wallet".tr,
                onTap: controller.goToWallet,
              ),
              _ActionRow(
                icon: Icons.support_agent_outlined,
                label: "profile_complaints".tr,
                onTap: controller.goToComplaints,
              ),
              _ActionRow(
                icon: Icons.notifications_active_outlined,
                label: "notification_settings_title".tr,
                onTap: controller.goToNotificationSettings,
              ),
              _ActionRow(
                icon: Icons.lock_outline,
                label: "profile_change_password".tr,
                onTap: controller.goToChangePassword,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPadding.p8),
        FadeSlideIn(
          delay: const Duration(milliseconds: 280),
          child: _SectionCard(
            icon: Icons.warning_amber_rounded,
            iconColor: ColorManager.colorError300,
            title: "profile_section_danger".tr,
            children: [
              Obx(
                () => _ActionRow(
                  icon: Icons.logout,
                  label: "profile_logout".tr,
                  destructive: true,
                  onTap: controller.loggingOut.value
                      ? null
                      : () => _confirm(
                          title: "profile_logout".tr,
                          message: "profile_logout_confirm_message".tr,
                          onConfirm: controller.logout,
                        ),
                ),
              ),
              Obx(
                () => _ActionRow(
                  icon: Icons.phonelink_erase_outlined,
                  label: "profile_logout_all".tr,
                  destructive: true,
                  isLast: true,
                  onTap: controller.loggingOut.value
                      ? null
                      : () => _confirm(
                          title: "profile_logout_all".tr,
                          message: "profile_logout_all_confirm_message".tr,
                          onConfirm: controller.logoutAll,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: ColorManager.colorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: FontSize.s16,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              const SizedBox(height: AppPadding.p8),
              Text(
                message,
                style: TextStyle(
                  fontSize: FontSize.s13,
                  color: ColorManager.colorGrey6,
                ),
              ),
              const SizedBox(height: AppPadding.p20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: "common_cancel".tr,
                      backgroundColor: ColorManager.colorBackground,
                      fontColor: ColorManager.colorFontPrimary,
                      radius: 12,
                      minHeight: 42,
                      onPressed: Get.back,
                    ),
                  ),
                  const SizedBox(width: AppPadding.p12),
                  Expanded(
                    child: AppButton(
                      text: "common_confirm".tr,
                      backgroundColor: ColorManager.colorError300,
                      radius: 12,
                      minHeight: 42,
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.isPhoneVerified,
  });

  final String name;
  final String phone;
  final String? photoUrl;
  final bool isPhoneVerified;

  @override
  Widget build(BuildContext context) {
    final statusColor = isPhoneVerified
        ? ColorManager.colorGreen3
        : ColorManager.colorOrange;
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorManager.colorPrimary.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: UserAvatarWidget(image: photoUrl, radius: 28),
            ),
            PositionedDirectional(
              bottom: -2,
              end: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: ColorManager.colorWhite,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPhoneVerified ? Icons.verified : Icons.error_outline,
                  size: 18,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppPadding.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.colorGrey6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(AppSize.s16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? ColorManager.colorPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(AppSize.s16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.p8),
          ...children,
        ],
      ),
    );
  }
}

class _AccountInfoBox extends StatelessWidget {
  const _AccountInfoBox({required this.nationalId, required this.joinDate});

  final String? nationalId;
  final String joinDate;

  @override
  Widget build(BuildContext context) {
    final joinItem = TripInfoItem(
      icon: Icons.calendar_today_outlined,
      weight: FontWeight.w400,
      title: joinDate,
      subtitle: "profile_label_join_date".tr,
    );
    if (nationalId == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: ColorManager.colorBackground.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: joinItem,
      );
    }
    return TripInfoBox(
      start: TripInfoItem(
        icon: Icons.credit_card_outlined,
        weight: FontWeight.w400,
        title: nationalId!,
        subtitle: "profile_label_national_id".tr,
      ),
      end: joinItem,
    );
  }
}

/// فاصل غير مكتمل: يبدأ من نهاية الصف (الجهة اليسرى في RTL) ويغطي جزءاً منه.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FractionallySizedBox(
        widthFactor: 1.0,
        child: Divider(
          height: 1,
          color: ColorManager.colorTextFieldEnabledBorder.withValues(
            alpha: 0.4,
          ),
        ),
      ),
    );
  }
}

/// أيقونة صف مع خط قصير (غير مكتمل) يتمدد تحتها بحركة ناعمة عند الظهور.
class _AnimatedRowIcon extends StatelessWidget {
  const _AnimatedRowIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.7 + 0.3 * value,
            child: Icon(icon, size: AppSize.s20, color: color),
          ),
          const SizedBox(height: 3),
          Container(
            width: 12 * value,
            height: 2,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
          child: Row(
            children: [
              _AnimatedRowIcon(icon: icon, color: ColorManager.colorGrey6),
              const SizedBox(width: AppPadding.p12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w400,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
        const _RowDivider(),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.isArabic,
    required this.onChanged,
    this.isLast = false,
  });

  final bool isArabic;
  final void Function(String) onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
          child: Row(
            children: [
              _AnimatedRowIcon(
                icon: Icons.language_outlined,
                color: ColorManager.colorGrey6,
              ),
              const SizedBox(width: AppPadding.p12),
              Expanded(
                child: Text(
                  "profile_language".tr,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w400,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ),
              _SegmentedToggle(
                options: [
                  ("ar", "profile_lang_arabic".tr),
                  ("en", "profile_lang_english".tr),
                ],
                selectedIndex: isArabic ? 0 : 1,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (!isLast) const _RowDivider(),
      ],
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<(String, String)> options;
  final int selectedIndex;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: AlignmentDirectional(selectedIndex == 0 ? -1 : 1, 0),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorManager.colorWhite,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < options.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(options[i].$1),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: FontSize.s12,
                          fontWeight: i == selectedIndex
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: i == selectedIndex
                              ? ColorManager.colorPrimary
                              : ColorManager.colorGrey6,
                        ),
                        child: Text(options[i].$2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? ColorManager.colorError300
        : ColorManager.colorFontPrimary;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                _AnimatedRowIcon(
                  icon: icon,
                  color: destructive
                      ? ColorManager.colorError300
                      : ColorManager.colorGrey6,
                ),
                const SizedBox(width: AppPadding.p12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: ColorManager.colorGrey6,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const _RowDivider(),
      ],
    );
  }
}
