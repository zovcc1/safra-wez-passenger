import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/data/models/trip_search_result_model.dart';
import 'package:safraa_passenger_app/data/models/trip_seat_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/create_booking_page/create_booking_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class CreateBookingPage extends GetView<CreateBookingPageController> {
  const CreateBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = controller.result;
    final priceValue = double.tryParse(result.basePrice) ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NormalAppBar(
        title: "create_booking_confirm_button".tr,
        backIcon: true,
      ),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshSeats,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppPadding.p16),
              children: [
                _SummaryCard(result: result),
                const SizedBox(height: AppPadding.p8),
                _SectionCard(
                  icon: Icons.event_seat_outlined,
                  title: "trips_seats_label".tr,
                  child: result.isOpenTrip
                      ? Obx(
                          () => _SeatsStepper(
                            value: controller.seatsCount.value,
                            max: result.availableSeats,
                            onChanged: controller.setSeatsCount,
                          ),
                        )
                      : const _SeatPicker(),
                ),
                const SizedBox(height: AppPadding.p8),
                if (controller.pickupMode != PickupMode.fixedPoint) ...[
                  const _PickupSection(),
                  const SizedBox(height: AppPadding.p8),
                ],
                _SectionCard(
                  icon: Icons.payments_outlined,
                  title: "create_booking_payment_method_title".tr,
                  child: Column(
                    children: [
                      Obx(
                        () => _PaymentMethodOption(
                          label: "create_booking_payment_wallet".tr,
                          icon: Icons.account_balance_wallet_outlined,
                          selected: controller.paymentMethod.value == "wallet",
                          onTap: () => controller.setPaymentMethod("wallet"),
                        ),
                      ),
                      Obx(
                        () => _PaymentMethodOption(
                          label: "create_booking_payment_cod".tr,
                          icon: Icons.payments_outlined,
                          selected:
                              controller.paymentMethod.value ==
                              "cash_on_delivery",
                          onTap: () =>
                              controller.setPaymentMethod("cash_on_delivery"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppPadding.p8),
                Obx(() {
                  final total = priceValue * controller.selectedSeatsQuantity;
                  return _CardShell(
                    child: Row(
                      children: [
                        Text(
                          "create_booking_total_label".tr,
                          style: TextStyle(
                            fontSize: FontSize.s13,
                            color: ColorManager.colorGrey6,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Money.format(total.toString()),
                          style: TextStyle(
                            fontSize: FontSize.s15,
                            fontWeight: FontWeight.w500,
                            color: ColorManager.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppPadding.p8),
                Obx(
                  () => AppButton(
                    text: "create_booking_confirm_button".tr,
                    radius: 12,
                    minHeight: 42,
                    loadingMode: controller.submitting.value,
                    onPressed: controller.submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// غلاف الكارد المشترك — نفس ظل وحشوة كارد البحث ونتائج الرحلات.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

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
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: ColorManager.colorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: ColorManager.colorPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: FontSize.s15,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppPadding.p4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: FontSize.s12,
                color: ColorManager.colorGrey6,
              ),
            ),
          ],
          const SizedBox(height: AppPadding.p8),
          child,
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final TripSearchResultModel result;

  @override
  Widget build(BuildContext context) {
    final badgeColor = result.isOpenTrip
        ? ColorManager.colorOrange
        : ColorManager.colorPrimary;
    final eventTime = result.isOpenTrip
        ? result.expiresAt
        : result.departureTime;
    final dateText = result.isOpenTrip
        ? "trips_expires_at".trParams({
            "date": DateConverter.dateToStringAR(eventTime),
            "time": "",
          }).trim()
        : DateConverter.dateToStringAR(eventTime);
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCardHeader(
            title: result.route.displayName,
            badge: result.isOpenTrip
                ? "trips_open_trip_badge".tr
                : "trips_scheduled_trip_badge".tr,
            badgeColor: badgeColor,
          ),
          const SizedBox(height: AppPadding.p8),
          TripInfoStrip(
            cells: [
              TripStripCell(
                flex: 5,
                icon: result.isOpenTrip
                    ? Icons.hourglass_bottom_rounded
                    : Icons.calendar_today_rounded,
                text: dateText,
              ),
              TripStripCell(
                flex: 3,
                icon: Icons.access_time_rounded,
                text: DateConverter.timeUTCToString(eventTime),
              ),
              TripStripCell(
                flex: 5,
                icon: Icons.directions_car_outlined,
                text: "trips_result_seats_available".trParams({
                  "vehicleType": result.vehicle.vehicleType,
                  "seats": "${result.availableSeats}",
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeatPicker extends GetView<CreateBookingPageController> {
  const _SeatPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.seatsLoadingState.value;

      if (state == LoadingState.loading || state == LoadingState.idle) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
          child: AppLoader(),
        );
      }

      if (state == LoadingState.hasError) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "create_booking_seats_error".tr,
                style: TextStyle(
                  fontSize: FontSize.s13,
                  color: ColorManager.colorGrey6,
                ),
              ),
              const SizedBox(height: AppPadding.p8),
              AppButton(
                text: "common_retry".tr,
                radius: 12,
                minHeight: 40,
                onPressed: controller.retryLoadSeats,
              ),
            ],
          ),
        );
      }

      if (state == LoadingState.doneWithNoData) {
        return Text(
          "create_booking_no_seats".tr,
          style: TextStyle(
            fontSize: FontSize.s13,
            color: ColorManager.colorGrey6,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppPadding.p8,
            runSpacing: AppPadding.p8,
            children: controller.seats.map((seat) {
              final selected = controller.selectedSeatIds.contains(
                seat.tripSeatId,
              );
              return _SeatChip(
                seat: seat,
                selected: selected,
                onTap: () => controller.toggleSeat(seat),
              );
            }).toList(),
          ),
          const SizedBox(height: AppPadding.p8),
          Text(
            "create_booking_seats_selected_count".trParams({
              "count": "${controller.selectedSeatIds.length}",
            }),
            style: TextStyle(
              fontSize: FontSize.s11,
              color: ColorManager.colorGrey6,
            ),
          ),
        ],
      );
    });
  }
}

class _SeatChip extends StatelessWidget {
  const _SeatChip({
    required this.seat,
    required this.selected,
    required this.onTap,
  });

  final TripSeatModel seat;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    if (!seat.isAvailable) {
      background = ColorManager.colorBackground.withValues(alpha: 0.7);
      foreground = ColorManager.colorDoveGray300;
    } else if (selected) {
      background = ColorManager.colorPrimary;
      foreground = Colors.white;
    } else {
      background = ColorManager.colorWhite;
      foreground = ColorManager.colorFontPrimary;
    }

    return GestureDetector(
      onTap: seat.isAvailable ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? ColorManager.colorPrimary
                : ColorManager.colorTextFieldEnabledBorder,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w500,
            color: foreground,
          ),
          child: Text(seat.seatNumber),
        ),
      ),
    );
  }
}

class _SeatsStepper extends StatelessWidget {
  const _SeatsStepper({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: ColorManager.colorWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorManager.colorTextFieldEnabledBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _stepButton(
                icon: Icons.remove,
                onTap: value > 1 ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 42,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    "$value",
                    key: ValueKey(value),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSize.s14,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.colorPrimary,
                    ),
                  ),
                ),
              ),
              _stepButton(
                icon: Icons.add,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "create_booking_max_seats_available".trParams({"max": "$max"}),
            style: TextStyle(
              fontSize: FontSize.s11,
              color: ColorManager.colorGrey6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepButton({required IconData icon, required VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? ColorManager.colorWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? ColorManager.colorFontPrimary
              : ColorManager.colorDoveGray300,
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  const _PaymentMethodOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12,
          vertical: AppPadding.p10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? ColorManager.colorPrimary.withValues(alpha: 0.08)
              : ColorManager.colorWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? ColorManager.colorPrimary
                : ColorManager.colorTextFieldEnabledBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? ColorManager.colorPrimary
                  : ColorManager.colorGrey6,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: FontSize.s13,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  color: selected
                      ? ColorManager.colorPrimary
                      : ColorManager.colorFontPrimary,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: selected
                  ? ColorManager.colorPrimary
                  : ColorManager.colorGrey6,
            ),
          ],
        ),
      ),
    );
  }
}

/// قسم نقطة الركوب (TR1): قائمة نقاط التجميع، أو زر لاختيار الموقع على الخريطة.
class _PickupSection extends GetView<CreateBookingPageController> {
  const _PickupSection();

  @override
  Widget build(BuildContext context) {
    final isDoor = controller.pickupMode == PickupMode.doorToDoor;
    return _SectionCard(
      icon: Icons.pin_drop_outlined,
      title: "create_booking_pickup_title".tr,
      subtitle: isDoor
          ? "create_booking_pickup_door_hint".tr
          : "create_booking_pickup_cp_hint".tr,
      child: isDoor ? _doorToDoor() : _collectionPoints(),
    );
  }

  Widget _collectionPoints() {
    return Obx(
      () => Column(
        children: controller.result.collectionPoints.map((point) {
          final selected =
              controller.selectedCollectionPointId.value ==
              point.collectionPointId;
          return _PaymentMethodOption(
            label: point.name,
            icon: Icons.pin_drop_outlined,
            selected: selected,
            onTap: () =>
                controller.selectCollectionPoint(point.collectionPointId),
          );
        }).toList(),
      ),
    );
  }

  Widget _doorToDoor() {
    return Obx(() {
      final picked = controller.pickup.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (picked != null) ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: ColorManager.colorPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    picked.address?.isNotEmpty == true
                        ? picked.address!
                        : "${picked.latitude!.toStringAsFixed(5)}, ${picked.longitude!.toStringAsFixed(5)}",
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      color: ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppPadding.p8),
          ],
          AppButton(
            text: picked == null
                ? "create_booking_pickup_choose".tr
                : "create_booking_pickup_change".tr,
            backgroundColor: ColorManager.colorWhite,
            fontColor: ColorManager.colorFontPrimary,
            border: Border.all(color: ColorManager.colorTextFieldEnabledBorder),
            radius: 12,
            minHeight: 40,
            onPressed: controller.pickOnMap,
          ),
        ],
      );
    });
  }
}
