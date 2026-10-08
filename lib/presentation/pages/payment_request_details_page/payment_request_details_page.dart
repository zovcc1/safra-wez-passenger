import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/payment_request_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/pages/payment_request_details_page/payment_request_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class PaymentRequestDetailsPage
    extends GetView<PaymentRequestDetailsPageController> {
  const PaymentRequestDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NormalAppBar(title: "payment_request_title".tr, backIcon: true),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.retry,
            child: Obx(() {
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
                      child: ErrorPlaceholderWidget(
                        title: "payment_request_error_title".tr,
                      ),
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
              return _content(controller.request.value!);
            }),
          ),
        ),
      ),
    );
  }

  Widget _content(PaymentRequestModel r) {
    final route = r.target?.route;
    final departure = r.target?.departureTime;
    final color = _statusColor(r.status);
    final seatsText = r.seats.isEmpty
        ? "${r.seatsCount}"
        : r.seats.map((s) => s.seatNumber).join("، ");

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        // ---- الحالة + المبلغ
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(r),
                          style: TextStyle(
                            fontSize: FontSize.s14,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                        if (!r.isPending) ...[
                          const SizedBox(height: 2),
                          Text(
                            _terminalText(r),
                            style: TextStyle(
                              fontSize: FontSize.s11,
                              color: ColorManager.colorGrey6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (r.isPending) ...[
                const SizedBox(height: AppPadding.p8),
                Obx(() {
                  final s = controller.secondsLeft.value;
                  final mm = (s ~/ 60).toString().padLeft(2, "0");
                  final ss = (s % 60).toString().padLeft(2, "0");
                  final urgent = s < 60;
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TripCardChip(
                      icon: Icons.timer_outlined,
                      color: urgent
                          ? ColorManager.colorError500
                          : ColorManager.colorOrange,
                      label: "payment_request_time_left".trParams({
                        "time": "$mm:$ss",
                      }),
                    ),
                  );
                }),
              ],
              const SizedBox(height: AppPadding.p8),
              const TripCardDivider(),
              const SizedBox(height: AppPadding.p8),
              Center(
                child: Text(
                  "payment_request_amount".tr,
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    color: ColorManager.colorGrey6,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  // المبلغ نص من الخادم ولا يُحوَّل إلى float.
                  Money.format(r.amount),
                  style: TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPadding.p8),
        // ---- الرحلة
        _card(
          delayMs: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (route != null) ...[
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: ColorManager.colorPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.alt_route_rounded,
                        size: 18,
                        color: ColorManager.colorPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        route.displayName,
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w500,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.p8),
              ],
              TripInfoStrip(
                cells: [
                  if (departure != null) ...[
                    TripStripCell(
                      flex: 5,
                      icon: Icons.calendar_today_rounded,
                      text: DateConverter.dateToStringAR(departure),
                    ),
                    TripStripCell(
                      flex: 3,
                      icon: Icons.access_time_rounded,
                      text: DateConverter.timeUTCToString(departure),
                    ),
                  ],
                  TripStripCell(
                    flex: 4,
                    icon: Icons.event_seat_outlined,
                    text: seatsText,
                  ),
                ],
              ),
              const SizedBox(height: AppPadding.p8),
              TripCardChip(
                icon: Icons.account_balance_wallet_outlined,
                color: ColorManager.colorPrimary,
                label:
                    "${"payment_request_payment_method".tr}: ${"create_booking_payment_wallet_short".tr}",
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPadding.p8),
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (r.isPending) ...[
                Obx(() {
                  if (!controller.insufficientBalance.value) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p8),
                    child: AppButton(
                      text: "payment_request_top_up_wallet".tr,
                      backgroundColor: ColorManager.colorWhite,
                      fontColor: ColorManager.colorPrimary,
                      border: Border.all(
                        color: ColorManager.colorPrimary.withValues(alpha: 0.4),
                      ),
                      radius: 12,
                      minHeight: 42,
                      onPressed: controller.openWallet,
                    ),
                  );
                }),
                Obx(
                  () => AppButton(
                    text: "payment_request_approve".tr,
                    radius: 12,
                    minHeight: 42,
                    loadingMode: controller.acting.value,
                    onPressed: controller.acting.value
                        ? null
                        : controller.approve,
                  ),
                ),
                const SizedBox(height: AppPadding.p8),
                Obx(
                  () => AppButton(
                    text: "payment_request_reject".tr,
                    backgroundColor: ColorManager.colorError500.withValues(
                      alpha: 0.08,
                    ),
                    fontColor: ColorManager.colorError500,
                    border: Border.all(
                      color: ColorManager.colorError500.withValues(alpha: 0.4),
                    ),
                    radius: 12,
                    minHeight: 42,
                    onPressed: controller.acting.value
                        ? null
                        : controller.reject,
                  ),
                ),
              ] else if (r.status == "approved")
                AppButton(
                  text: "payment_request_open_booking".tr,
                  radius: 12,
                  minHeight: 42,
                  onPressed: controller.openBooking,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child, int delayMs = 0}) => FadeSlideIn(
    delay: Duration(milliseconds: delayMs),
    child: Container(
      width: double.infinity,
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
    ),
  );

  String _statusLabel(PaymentRequestModel r) => switch (r.status) {
    "pending" => "payment_request_status_pending".tr,
    "approved" => "payment_request_status_approved".tr,
    "rejected" => "payment_request_status_rejected".tr,
    "expired" => "payment_request_status_expired".tr,
    "cancelled" => "payment_request_status_cancelled".tr,
    _ => r.status,
  };

  Color _statusColor(String status) => switch (status) {
    "approved" => ColorManager.colorGreen3,
    "pending" => ColorManager.colorOrange,
    _ => ColorManager.colorError300,
  };

  String _terminalText(PaymentRequestModel r) {
    switch (r.status) {
      case "approved":
        return "payment_request_terminal_approved".tr;
      case "rejected":
        return "payment_request_terminal_rejected".tr;
      case "expired":
        return "payment_request_terminal_expired".tr;
      case "cancelled":
        return r.terminalReason == "trip_handed_off"
            ? "payment_request_terminal_handed_off".tr
            : (r.terminalReason == "trip_cancelled"
                  ? "payment_request_terminal_trip_cancelled".tr
                  : "payment_request_terminal_provider_cancelled".tr);
      default:
        return "";
    }
  }
}
