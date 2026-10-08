import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/payment_request_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
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
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p8),
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

    final seatsText = request.seatsCount == 1
        ? "booking_details_seats_one".tr
        : "booking_details_seats_many".trParams({
            "count": "${request.seatsCount}",
          });

    return CompactTripCard(
      onTap: onTap,
      title: route?.displayName ?? "#${request.paymentRequestId}",
      badge: "payment_request_status_${request.status}".tr,
      badgeColor: color,
      details: [
        if (departure != null) ...[
          TextSpan(
            text: "${DateFormat("EEEE d MMMM", "ar").format(departure)} · ",
          ),
          CompactTripCard.strong(DateConverter.timeUTCToString(departure)),
          const TextSpan(text: " · "),
        ],
        TextSpan(text: seatsText),
      ],
      // المبلغ نص من الخادم ولا يُحوَّل إلى float.
      price: Money.format(request.amount),
      extra: request.isPending && request.expiresAt != null
          ? _Meta(
              icon: Icons.timer_outlined,
              color: ColorManager.colorOrange,
              text: "payment_requests_expires_at".trParams({
                "time": DateConverter.timeUTCToString(request.expiresAt),
              }),
            )
          : null,
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? ColorManager.colorGrey6),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: FontSize.s12,
              color: color ?? ColorManager.colorDoveGray600,
            ),
          ),
        ),
      ],
    );
  }
}
