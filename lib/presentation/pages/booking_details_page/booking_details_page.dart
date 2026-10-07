import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/star_rating_widget.dart';
import 'package:safraa_passenger_app/presentation/pages/booking_details_page/booking_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/booking_status_display.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class BookingDetailsPage extends GetView<BookingDetailsPageController> {
  const BookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NormalAppBar(title: "booking_details_title".tr, backIcon: true),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.retry,
            child: Obx(() => _body()),
          ),
        ),
      ),
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
            child: ErrorPlaceholderWidget(
              title: "booking_details_error_title".tr,
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

    final booking = controller.booking.value!;
    var delayMs = 0;
    const step = 70;
    Widget staggered(Widget child) {
      final widget = FadeSlideIn(
        delay: Duration(milliseconds: delayMs),
        child: child,
      );
      delayMs += step;
      return widget;
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        staggered(_StatusHeader(booking: booking)),
        const SizedBox(height: AppPadding.p8),
        staggered(_RouteCard(booking: booking)),
        if (booking.pickup != null) ...[
          const SizedBox(height: AppPadding.p8),
          staggered(
            _PickupCard(
              pickup: booking.pickup!,
              onChange: controller.canChangePickup
                  ? controller.changePickup
                  : null,
              onTrack: controller.canTrack ? controller.openTracking : null,
              busy: controller.changingPickup.value,
            ),
          ),
        ],
        const SizedBox(height: AppPadding.p8),
        staggered(_BookingInfoCard(booking: booking)),
        if (_hasTimeline(booking)) ...[
          const SizedBox(height: AppPadding.p8),
          staggered(_TimelineCard(booking: booking)),
        ],
        const SizedBox(height: AppPadding.p8),
        staggered(_PriceSummaryCard(booking: booking)),
        if (booking.canRate || booking.rating != null) ...[
          const SizedBox(height: AppPadding.p8),
          staggered(
            _RatingCard(booking: booking, onRate: controller.openRating),
          ),
        ],
        const SizedBox(height: AppPadding.p8),
        staggered(
          AppButton(
            text: "booking_details_file_complaint".tr,
            icon: Icon(
              Icons.report_gmailerrorred_outlined,
              size: 18,
              color: ColorManager.colorError300,
            ),
            backgroundColor: ColorManager.colorError300.withValues(alpha: 0.08),
            fontColor: ColorManager.colorError300,
            border: Border.all(
              color: ColorManager.colorError300.withValues(alpha: 0.4),
            ),
            radius: 12,
            minHeight: 42,
            onPressed: controller.fileComplaint,
          ),
        ),
      ],
    );
  }

  bool _hasTimeline(BookingModel booking) =>
      booking.createdAt != null ||
      booking.confirmedAt != null ||
      booking.boardedAt != null ||
      booking.noShowAt != null;
}

String _paymentMethodLabel(String method) => switch (method) {
  "wallet" => "create_booking_payment_wallet_short".tr,
  "cash_on_delivery" => "create_booking_payment_cod_short".tr,
  _ => method,
};

String _dateTime(DateTime? date) => date == null
    ? "booking_details_no_date".tr
    : "trips_departure_at".trParams({
        "date": DateConverter.dateToStringAR(date),
        "time": DateConverter.timeUTCToString(date),
      });

/// إطار بصري موحّد لكل بطاقات هذه الشاشة: أبيض + ظل خفيف + زوايا دائرية،
/// بنفس مواصفات بطاقات trips_page و bookings_page كي تبقى الواجهة متسقة.
class _CardFrame extends StatelessWidget {
  const _CardFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final status = BookingStatusDisplay.of(booking.status);
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCardHeader(
            icon: Icons.event_seat_outlined,
            title:
                "${"booking_details_booking_number".tr} #${booking.bookingId}",
            badge: status.label,
            badgeColor: status.color,
          ),
          if (booking.transferredByHandoff) ...[
            const SizedBox(height: 8),
            TripCardChip(
              icon: Icons.swap_horiz_rounded,
              color: ColorManager.colorOrange,
              label: "booking_details_transferred_by_handoff".tr,
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final journey = booking.journey;
    final route = journey?.route;
    final isOpenTrip = journey?.isOpenTrip == true;

    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionTitle(
                icon: Icons.route_outlined,
                title: "booking_details_section_trip".tr,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (isOpenTrip
                              ? ColorManager.colorOrange
                              : ColorManager.colorPrimary)
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOpenTrip
                      ? "booking_details_trip_type_open".tr
                      : "booking_details_trip_type_scheduled".tr,
                  style: TextStyle(
                    fontSize: FontSize.s10_5,
                    fontWeight: FontWeight.w500,
                    color: isOpenTrip
                        ? ColorManager.colorOrange
                        : ColorManager.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.p8),
          if (route?.origin != null && route?.destination != null)
            _RoutePoints(
              origin: route!.origin!.displayName,
              destination: route.destination!.displayName,
            )
          else
            Text(
              route?.displayName ?? "",
              style: TextStyle(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w500,
                color: ColorManager.colorFontPrimary,
              ),
            ),
          const SizedBox(height: AppPadding.p8),
          Container(height: 1, color: ColorManager.colorDivider),
          const SizedBox(height: AppPadding.p8),
          Row(
            children: [
              Icon(
                isOpenTrip
                    ? Icons.hourglass_bottom_outlined
                    : Icons.schedule_outlined,
                size: 16,
                color: ColorManager.colorGrey6,
              ),
              const SizedBox(width: 6),
              Text(
                isOpenTrip
                    ? "booking_details_expires".tr
                    : "booking_details_departure_time".tr,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.colorGrey6,
                ),
              ),
              const Spacer(),
              Text(
                isOpenTrip
                    ? _dateTime(journey?.expiresAt)
                    : _dateTime(journey?.departureTime),
                style: TextStyle(
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutePoints extends StatelessWidget {
  const _RoutePoints({required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ColorManager.colorPrimary,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 1.5, height: 22, color: ColorManager.colorDivider),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ColorManager.colorOrange,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoutePointLabel(
                label: "trips_route_from_label".tr,
                value: origin,
              ),
              const SizedBox(height: 12),
              _RoutePointLabel(
                label: "trips_route_to_label".tr,
                value: destination,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutePointLabel extends StatelessWidget {
  const _RoutePointLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: FontSize.s11,
            color: ColorManager.colorGrey6,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w500,
              color: ColorManager.colorFontPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.confirmation_number_outlined,
            title: "booking_details_section_booking".tr,
          ),
          const SizedBox(height: AppPadding.p8),
          _InfoGrid(
            tiles: [
              _InfoTile(
                label: "booking_details_booking_number".tr,
                value: "#${booking.bookingId}",
              ),
              _InfoTile(
                label: "trips_seats_label".tr,
                value: "${booking.seatsCount}",
              ),
              if (booking.seats.isNotEmpty)
                _InfoTile(
                  label: "booking_details_seat_numbers".tr,
                  value: booking.seats
                      .map((s) => s.seatNumber)
                      .join("common_list_separator".tr),
                ),
              _InfoTile(
                label: "create_booking_payment_method_title".tr,
                value: _paymentMethodLabel(booking.paymentMethod),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final steps = <_TimelineStep>[
      if (booking.createdAt != null)
        _TimelineStep(
          icon: Icons.add_circle_outline,
          label: "booking_details_created_at".tr,
          date: booking.createdAt,
          color: ColorManager.colorGrey6,
        ),
      if (booking.confirmedAt != null)
        _TimelineStep(
          icon: Icons.check_circle_outline,
          label: "booking_details_confirmed_at".tr,
          date: booking.confirmedAt,
          color: ColorManager.colorGreen3,
        ),
      if (booking.boardedAt != null)
        _TimelineStep(
          icon: Icons.directions_bus_outlined,
          label: "booking_details_boarded_at".tr,
          date: booking.boardedAt,
          color: ColorManager.colorPrimary,
        ),
      if (booking.noShowAt != null)
        _TimelineStep(
          icon: Icons.cancel_outlined,
          label: "booking_details_no_show_at".tr,
          date: booking.noShowAt,
          color: ColorManager.colorError300,
        ),
    ];

    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.history_outlined,
            title: "booking_details_section_timeline".tr,
          ),
          const SizedBox(height: AppPadding.p8),
          for (var i = 0; i < steps.length; i++)
            _TimelineRow(step: steps[i], isLast: i == steps.length - 1),
        ],
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.date,
    required this.color,
  });

  final IconData icon;
  final String label;
  final DateTime? date;
  final Color color;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.isLast});

  final _TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(step.icon, size: 14, color: step.color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: ColorManager.colorDivider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppPadding.p16,
                top: 2,
              ),
              child: Row(
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.colorFontPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _dateTime(step.date),
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.colorGrey6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _CardFrame(
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: ColorManager.colorPrimary,
            size: 22,
          ),
          const SizedBox(width: AppPadding.p8),
          Text(
            "booking_details_total_amount".tr,
            style: TextStyle(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w500,
              color: ColorManager.colorFontPrimary,
            ),
          ),
          const Spacer(),
          Text(
            Money.format(booking.totalAmount),
            style: TextStyle(
              fontSize: FontSize.s16,
              fontWeight: FontWeight.w500,
              color: ColorManager.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// زر "قيّم" يعتمد على can_rate فقط. بعد التقييم يُعرض Read-only. comment=null
/// (لم يكتب أو أُخفي) لا يظهر منه شيء بالحالتين.
class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.booking, required this.onRate});

  final BookingModel booking;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) {
    final rating = booking.rating;
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.star_outline_rounded,
            title: "booking_details_section_rating".tr,
          ),
          const SizedBox(height: AppPadding.p8),
          if (rating != null) ...[
            _ReadOnlyScore(
              label: "rating_provider".tr,
              score: rating.providerScore,
            ),
            const SizedBox(height: AppPadding.p8),
            _ReadOnlyScore(
              label: "rating_vehicle".tr,
              score: rating.vehicleScore,
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: AppPadding.p8),
              Text(
                rating.comment!,
                style: TextStyle(
                  fontSize: FontSize.s13,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
            ],
          ] else
            AppButton(
              text: "booking_details_rate".tr,
              radius: 12,
              minHeight: 42,
              onPressed: onRate,
            ),
        ],
      ),
    );
  }
}

class _ReadOnlyScore extends StatelessWidget {
  const _ReadOnlyScore({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s13,
              color: ColorManager.colorGrey6,
            ),
          ),
        ),
        StarRatingWidget(value: score, size: 22),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          title,
          style: TextStyle(
            fontSize: FontSize.s15,
            fontWeight: FontWeight.w500,
            color: ColorManager.colorFontPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoTile {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.tiles});

  final List<_InfoTile> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppPadding.p8,
        crossAxisSpacing: AppPadding.p8,
        mainAxisExtent: 48,
      ),
      itemBuilder: (context, index) => _InfoTileView(tile: tiles[index]),
    );
  }
}

class _InfoTileView extends StatelessWidget {
  const _InfoTileView({required this.tile});

  final _InfoTile tile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p8,
        vertical: AppPadding.p4,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tile.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: FontSize.s10,
              color: ColorManager.colorGrey6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tile.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w500,
              color: ColorManager.colorFontPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// نقطة الركوب (TR1) مع زرّي تغييرها وتتبع السائق.
class _PickupCard extends StatelessWidget {
  const _PickupCard({
    required this.pickup,
    required this.onChange,
    required this.onTrack,
    required this.busy,
  });

  final BookingPickupModel pickup;
  final VoidCallback? onChange;
  final VoidCallback? onTrack;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final sourceLabel = switch (pickup.source) {
      "gps" => "pickup_source_gps".tr,
      "pin" => "pickup_source_pin".tr,
      _ => "pickup_source_collection_point".tr,
    };
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.pin_drop_outlined,
            title: "booking_details_section_pickup".tr,
          ),
          const SizedBox(height: AppPadding.p8),
          Text(
            pickup.address?.isNotEmpty == true
                ? pickup.address!
                : "booking_details_pickup_no_address".tr,
            style: TextStyle(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w500,
              color: ColorManager.colorFontPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sourceLabel,
            style: TextStyle(
              fontSize: FontSize.s12,
              color: ColorManager.colorGrey6,
            ),
          ),
          if (pickup.coordinatesRedacted) ...[
            const SizedBox(height: 4),
            Text(
              "booking_details_pickup_redacted".tr,
              style: TextStyle(
                fontSize: FontSize.s11,
                color: ColorManager.colorGrey6,
              ),
            ),
          ],
          if (onTrack != null || onChange != null) ...[
            const SizedBox(height: AppPadding.p8),
            Row(
              children: [
                if (onTrack != null)
                  Expanded(
                    child: AppButton(
                      text: "booking_details_track_driver".tr,
                      radius: 12,
                      minHeight: 40,
                      onPressed: onTrack,
                    ),
                  ),
                if (onTrack != null && onChange != null)
                  const SizedBox(width: AppPadding.p8),
                if (onChange != null)
                  Expanded(
                    child: AppButton(
                      text: "booking_details_change_pickup".tr,
                      backgroundColor: ColorManager.colorBackground,
                      fontColor: ColorManager.colorFontPrimary,
                      radius: 12,
                      minHeight: 40,
                      loadingMode: busy,
                      onPressed: busy ? null : onChange,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
