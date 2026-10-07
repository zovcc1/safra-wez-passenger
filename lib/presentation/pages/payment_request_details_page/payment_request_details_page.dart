import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/payment_request_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/info_pill.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
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
      backgroundColor: ColorManager.colorBackground,
      appBar: NormalAppBar(title: "payment_request_title".tr, backIcon: true),
      body: SafeArea(
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payments_outlined,
                      size: 20,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: AppPadding.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(r),
                          style: TextStyle(
                            fontSize: FontSize.s15,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        if (!r.isPending) ...[
                          const SizedBox(height: 2),
                          Text(
                            _terminalText(r),
                            style: TextStyle(
                              fontSize: FontSize.s12,
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
                const SizedBox(height: AppPadding.p10),
                Obx(() {
                  final s = controller.secondsLeft.value;
                  final mm = (s ~/ 60).toString().padLeft(2, "0");
                  final ss = (s % 60).toString().padLeft(2, "0");
                  final urgent = s < 60;
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InfoPill(
                      icon: Icons.timer_outlined,
                      color: urgent
                          ? ColorManager.colorError500
                          : ColorManager.colorOrange,
                      text: "payment_request_time_left".trParams({
                        "time": "$mm:$ss",
                      }),
                    ),
                  );
                }),
              ],
              const SizedBox(height: AppPadding.p10),
              Divider(
                height: 1,
                color: ColorManager.colorTextFieldEnabledBorder,
              ),
              const SizedBox(height: AppPadding.p10),
              Center(
                child: Text(
                  "payment_request_amount".tr,
                  style: TextStyle(
                    fontSize: FontSize.s12,
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
                    fontSize: FontSize.s24,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPadding.p12),
        // ---- الرحلة
        _card(
          delayMs: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (route != null)
                Row(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: AppSize.s20,
                      color: ColorManager.colorPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        route.displayName,
                        style: TextStyle(
                          fontSize: FontSize.s15,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              if (departure != null) ...[
                const SizedBox(height: AppPadding.p8),
                InfoPill(
                  icon: Icons.schedule_outlined,
                  text: "trips_departure_at".trParams({
                    "date": DateConverter.dateToStringAR(departure),
                    "time": DateConverter.timeUTCToString(departure),
                  }),
                ),
              ],
              const SizedBox(height: AppPadding.p10),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.event_seat_outlined,
                      label: "payment_request_seats".tr,
                      value: seatsText,
                    ),
                  ),
                  const SizedBox(width: AppPadding.p8),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: "payment_request_payment_method".tr,
                      value: "create_booking_payment_wallet_short".tr,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPadding.p12),
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p10,
        vertical: AppPadding.p8,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorManager.colorPrimary),
          const SizedBox(width: AppPadding.p8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSize.s10,
                    color: ColorManager.colorGrey6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
