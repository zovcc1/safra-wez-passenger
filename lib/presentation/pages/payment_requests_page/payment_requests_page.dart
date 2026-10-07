import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/payment_request_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/info_pill.dart';
import 'package:safraa_passenger_app/presentation/pages/payment_requests_page/payment_requests_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

/// تبويب طلبات الدفع: قائمة بترقيم cursor مع فلتر بالحالة، والضغط يفتح التفاصيل.
class PaymentRequestsPage extends GetView<PaymentRequestsPageController> {
  const PaymentRequestsPage({super.key});

  static const _filters = <String?>[
    null,
    "pending",
    "approved",
    "rejected",
    "expired",
    "cancelled",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _filterBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.reload,
            child: Obx(_body),
          ),
        ),
      ],
    );
  }

  Widget _filterBar() {
    return SizedBox(
      height: 54,
      child: Obx(() {
        // القراءة هنا (وليس داخل itemBuilder) كي يتتبعها Obx.
        final selected = controller.statusFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
            vertical: AppPadding.p10,
          ),
          itemCount: _filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppPadding.p8),
          itemBuilder: (context, i) {
            final status = _filters[i];
            final isSelected = selected == status;
            return GestureDetector(
              onTap: () => controller.setFilter(status),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorManager.colorPrimary
                      : ColorManager.colorWhite,
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : ColorManager.colorGrey6,
                  ),
                  child: Text(
                    status == null
                        ? "notifications_filter_all".tr
                        : "payment_request_status_$status".tr,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
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
            child: ErrorPlaceholderWidget(title: "payment_requests_error".tr),
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
              icon: Icons.payments_outlined,
              title: "payment_requests_empty_title".tr,
              subtitle: "payment_requests_empty_subtitle".tr,
            ),
          ),
        ],
      );
    }

    final items = controller.requests;
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
          child: _RequestCard(
            request: items[index],
            onTap: () => controller.open(items[index]),
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onTap});

  final PaymentRequestModel request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final route = request.target?.route;
    final departure = request.target?.departureTime;
    final color = switch (request.status) {
      "approved" => ColorManager.colorGreen3,
      "pending" => ColorManager.colorOrange,
      _ => ColorManager.colorError300,
    };

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: AppSize.s20,
                      color: ColorManager.colorPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        route?.displayName ?? "#${request.paymentRequestId}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: FontSize.s15,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "payment_request_status_${request.status}".tr,
                        style: TextStyle(
                          fontSize: FontSize.s10_5,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.p8),
                Wrap(
                  spacing: AppPadding.p8,
                  runSpacing: AppPadding.p8,
                  children: [
                    InfoPill(
                      icon: Icons.event_seat_outlined,
                      text: "payment_requests_seats_count".trParams({
                        "count": "${request.seatsCount}",
                      }),
                    ),
                    if (departure != null)
                      InfoPill(
                        icon: Icons.schedule_outlined,
                        text: "trips_departure_at".trParams({
                          "date": DateConverter.dateToStringAR(departure),
                          "time": DateConverter.timeUTCToString(departure),
                        }),
                      ),
                    if (request.isPending && request.expiresAt != null)
                      InfoPill(
                        icon: Icons.timer_outlined,
                        color: ColorManager.colorOrange,
                        text: "payment_requests_expires_at".trParams({
                          "time": DateConverter.timeUTCToString(
                            request.expiresAt,
                          ),
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: AppPadding.p8),
                Divider(
                  height: 1,
                  color: ColorManager.colorTextFieldEnabledBorder,
                ),
                const SizedBox(height: AppPadding.p8),
                Row(
                  children: [
                    // المبلغ نص من الخادم ولا يُحوَّل إلى float.
                    Expanded(
                      child: Text(
                        Money.format(request.amount),
                        style: TextStyle(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.colorPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: ColorManager.colorGrey6,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
