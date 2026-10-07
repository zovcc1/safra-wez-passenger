import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/notification_models.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/info_pill.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/notifications_page/notifications_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

/// صندوق الوارد. تُفتح كصفحة مستقلة عبر جرس الإشعارات بشريط main_page.
class NotificationsPage extends GetView<NotificationsPageController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
      appBar: NormalAppBar(
        title: "main_tab_notifications".tr,
        backIcon: true,
        actions: [
          IconButton(
            tooltip: "notification_settings_title".tr,
            onPressed: controller.openSettings,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _filters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.reload,
                child: Obx(_body),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    return Obx(() {
      final selected = controller.statusFilter.value;
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p16,
          vertical: AppPadding.p10,
        ),
        child: Row(
          children: [
            _FilterPill(
              label: "notifications_filter_all".tr,
              selected: selected == null,
              onTap: () => controller.setFilter(null),
            ),
            const SizedBox(width: AppPadding.p8),
            _FilterPill(
              label: "notifications_filter_unread".tr,
              selected: selected == "unread",
              onTap: () => controller.setFilter("unread"),
            ),
          ],
        ),
      );
    });
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.loading || state == LoadingState.idle) {
      return const AppPageLoader();
    }

    if (state == LoadingState.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ErrorPlaceholderWidget(title: "notifications_error".tr),
          ),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: AppButton(
              text: "common_retry".tr,
              onPressed: controller.reload,
            ),
          ),
        ],
      );
    }

    if (state == LoadingState.doneWithNoData) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: EmptyStateWidget(
              icon: Icons.notifications_none_outlined,
              title: "notifications_empty_title".tr,
              subtitle: "notifications_empty_subtitle".tr,
            ),
          ),
        ],
      );
    }

    final items = controller.items;
    return ListView.separated(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p16,
        AppPadding.p4,
        AppPadding.p16,
        AppPadding.p16,
      ),
      itemCount: items.length + (controller.loadingMore.value ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p12),
      itemBuilder: (_, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.all(AppPadding.p8),
            child: AppLoader.dots(),
          );
        }
        return FadeSlideIn(
          delay: Duration(milliseconds: 40 * index.clamp(0, 8)),
          child: _NotificationTile(
            item: items[index],
            onTap: () => controller.open(items[index]),
          ),
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 34,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? ColorManager.colorPrimary : ColorManager.colorWhite,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: FontSize.s12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            color: selected ? Colors.white : ColorManager.colorGrey6,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final NotificationItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final created = item.createdAt?.toLocal();
    return Material(
      color: Colors.transparent,
      child: Ink(
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSize.s16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: AppPadding.p10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ColorManager.colorPrimary.withValues(
                      alpha: item.isRead ? 0.08 : 0.14,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon(item.type),
                    size: 18,
                    color: ColorManager.colorPrimary,
                  ),
                ),
                const SizedBox(width: AppPadding.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title نص لنوعَي الحملات فقط، و null لبقية الأنواع.
                      if (item.title != null && item.title!.isNotEmpty) ...[
                        Text(
                          item.title!,
                          style: TextStyle(
                            fontSize: FontSize.s14,
                            fontWeight: FontWeight.bold,
                            color: ColorManager.colorFontPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: FontSize.s13,
                          fontWeight: item.isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                      if (created != null) ...[
                        const SizedBox(height: AppPadding.p8),
                        InfoPill(
                          icon: Icons.schedule_outlined,
                          text:
                              "${DateConverter.dateToStringAR(created)} "
                              "${DateConverter.timeUTCToString(created)}",
                        ),
                      ],
                    ],
                  ),
                ),
                if (!item.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: ColorManager.colorPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _icon(String type) {
    if (type.startsWith("pickup_")) return Icons.directions_car_outlined;
    if (type.startsWith("payment_request")) return Icons.payments_outlined;
    if (type.startsWith("visa_")) return Icons.badge_outlined;
    if (type.startsWith("complaint_")) return Icons.support_agent_outlined;
    if (type.startsWith("wallet_")) {
      return Icons.account_balance_wallet_outlined;
    }
    if (type.startsWith("rating_")) return Icons.star_outline;
    if (type.startsWith("campaign_")) return Icons.campaign_outlined;
    if (type == "departure_reminder") return Icons.alarm;
    return Icons.event_seat_outlined;
  }
}
