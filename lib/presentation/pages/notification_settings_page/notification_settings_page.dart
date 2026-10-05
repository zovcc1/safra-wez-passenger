import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/info_pill.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/notification_settings_page/notification_settings_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class NotificationSettingsPage
    extends GetView<NotificationSettingsPageController> {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
      appBar: NormalAppBar(
        title: "notification_settings_title".tr,
        backIcon: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final state = controller.loadingState.value;
          if (state == LoadingState.loading || state == LoadingState.idle) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == LoadingState.hasError) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: ErrorPlaceholderWidget(
                    title: "notification_settings_error".tr,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppPadding.p16),
                  child: AppButton(
                    text: "common_retry".tr,
                    onPressed: controller.load,
                  ),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppPadding.p16),
            children: [
              _CardShell(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: AppSize.s20,
                      color: ColorManager.colorPrimary,
                    ),
                    const SizedBox(width: AppPadding.p8),
                    Expanded(
                      child: Text(
                        "notification_settings_hint".tr,
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          height: 1.4,
                          color: ColorManager.colorGrey6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppPadding.p12),
              ...controller.preferences.map(
                (pref) => Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p12),
                  child: _CardShell(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ColorManager.colorPrimary.withValues(
                              alpha: pref.enabled ? 0.12 : 0.06,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _categoryIcon(pref.category),
                            size: 18,
                            color: pref.enabled
                                ? ColorManager.colorPrimary
                                : ColorManager.colorDoveGray300,
                          ),
                        ),
                        const SizedBox(width: AppPadding.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "notification_category_${pref.category}".tr,
                                style: TextStyle(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.colorFontPrimary,
                                ),
                              ),
                              if (!pref.isOptional) ...[
                                const SizedBox(height: 4),
                                InfoPill(
                                  icon: Icons.lock_outline_rounded,
                                  text: "notification_category_required".tr,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Switch(
                          activeThumbColor: ColorManager.colorPrimary,
                          value: pref.enabled,
                          // is_optional:false → مفعّل ومعطّل عن التغيير.
                          onChanged:
                              pref.isOptional &&
                                  !controller.saving.contains(pref.category)
                              ? (v) => controller.toggle(pref, v)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

IconData _categoryIcon(String category) => switch (category) {
  "transactional" => Icons.receipt_long_outlined,
  "reminder" => Icons.alarm_outlined,
  "promotional" => Icons.local_offer_outlined,
  "service" => Icons.campaign_outlined,
  _ => Icons.notifications_outlined,
};

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p12,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(AppSize.s16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
