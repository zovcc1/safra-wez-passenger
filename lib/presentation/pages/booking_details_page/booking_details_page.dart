import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:intl/intl.dart' show DateFormat;
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
        if (booking.canRate || booking.rating != null) ...[
          const SizedBox(height: AppPadding.p8),
          staggered(
            _RatingCard(booking: booking, onRate: controller.openRating),
          ),
        ],
        const SizedBox(height: AppPadding.p8),
        staggered(
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: controller.fileComplaint,
              child: Text(
                "booking_details_file_complaint".tr,
                style: TextStyle(
                  fontSize: FontSize.s13,
                  color: ColorManager.colorGrey6,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _paymentMethodLabel(String method) => switch (method) {
  "wallet" => "create_booking_payment_wallet_short".tr,
  "cash_on_delivery" => "create_booking_payment_cod_short".tr,
  _ => method,
};

/// تاريخ بلا سنة (مثل "5 أكتوبر"): السنة غير مفيدة في تفاصيل حجز قريب.
String _dateTime(DateTime? date) => date == null
    ? "booking_details_no_date".tr
    : "${DateFormat("d MMMM", "ar").format(date)} · "
          "${DateConverter.timeUTCToString(date)}";

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
    // حجز ملغى لرحلة ما زالت مجدولة: سطر واحد يشرح "التناقض" بدل شارتين متعارضتين.
    final cancelledOnActiveTrip =
        booking.status == "cancelled" && booking.journey?.isOpenTrip == false;
    final description = cancelledOnActiveTrip
        ? "booking_status_cancelled_trip_active_desc".tr
        : status.description;
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "booking_details_booking_label".tr,
                style: TextStyle(
                  fontSize: FontSize.s14,
                  color: ColorManager.colorGrey6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "#${booking.bookingId}",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: FontSize.s28,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    fontWeight: FontWeight.w500,
                    color: status.color,
                  ),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: FontSize.s12,
                color: ColorManager.colorGrey6,
              ),
            ),
          ],
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
    final date = isOpenTrip ? journey?.expiresAt : journey?.departureTime;
    final dateText = date == null
        ? "booking_details_no_date".tr
        : "${isOpenTrip ? "${"booking_details_expires".tr} " : ""}"
              "${DateFormat("EEEE d MMMM", "ar").format(date)}";

    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (route?.origin != null && route?.destination != null)
            _RoutePoints(
              origin: route!.origin!.displayName,
              destination: route.destination!.displayName,
            )
          else
            Text(
              route?.displayName ?? "",
              style: TextStyle(
                fontSize: FontSize.s15,
                fontWeight: FontWeight.w600,
                color: ColorManager.colorFontPrimary,
              ),
            ),
          const SizedBox(height: AppPadding.p8),
          const TripCardDivider(),
          const SizedBox(height: AppPadding.p8),
          Row(
            children: [
              Text(
                dateText,
                style: TextStyle(
                  fontSize: FontSize.s13,
                  color: ColorManager.colorGrey6,
                ),
              ),
              const Spacer(),
              if (date != null)
                Text(
                  DateConverter.timeUTCToString(date),
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.w600,
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

/// نقطتان (من/إلى): كل نقطة بنفس سطر اسم المدينة، والخط بينهما فقط.
class _RoutePoints extends StatelessWidget {
  const _RoutePoints({required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoutePointRow(
          label: "trips_route_from_label".tr,
          value: origin,
          color: ColorManager.colorPrimary,
          hasLine: true,
        ),
        _RoutePointRow(
          label: "trips_route_to_label".tr,
          value: destination,
          color: ColorManager.colorOrange,
          hasLine: false,
        ),
      ],
    );
  }
}

class _RoutePointRow extends StatelessWidget {
  const _RoutePointRow({
    required this.label,
    required this.value,
    required this.color,
    required this.hasLine,
  });

  final String label;
  final String value;
  final Color color;
  final bool hasLine;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 10,
            child: Column(
              children: [
                SizedBox(
                  height: 22,
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                if (hasLine)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: ColorManager.colorDivider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: hasLine ? 14 : 0),
              child: SizedBox(
                height: 22,
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بيانات الحجز كصفوف (عنوان/قيمة) بفواصل رفيعة، والإجمالي في آخر صف.
class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final seatNumbers = booking.seats
        .map((s) => s.seatNumber)
        .join("common_list_separator".tr);
    final rows = <_InfoRow>[
      _InfoRow(
        "booking_details_seats".tr,
        booking.seatsCount == 1
            ? "booking_details_seats_one".tr
            : "booking_details_seats_many".trParams({
                "count": "${booking.seatsCount}",
              }),
      ),
      if (booking.seats.isNotEmpty)
        _InfoRow("booking_details_seat_numbers".tr, seatNumbers),
      _InfoRow(
        "booking_details_payment".tr,
        _paymentMethodLabel(booking.paymentMethod),
      ),
      if (booking.createdAt != null)
        _InfoRow(
          "booking_details_booking_date".tr,
          _dateTime(booking.createdAt),
        ),
      // if (booking.confirmedAt != null)
      //   _InfoRow(
      //     "booking_details_confirmed_at".tr,
      //     _dateTime(booking.confirmedAt),
      //   ),
      if (booking.boardedAt != null)
        _InfoRow("booking_details_boarded_at".tr, _dateTime(booking.boardedAt)),
      if (booking.noShowAt != null)
        _InfoRow("booking_details_no_show_at".tr, _dateTime(booking.noShowAt)),
      _InfoRow(
        "booking_details_total_amount".tr,
        Money.format(booking.totalAmount),
        emphasized: true,
      ),
    ];
    return _CardFrame(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const TripCardDivider(),
            _InfoRowView(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value, {this.emphasized = false});

  final String label;
  final String value;
  final bool emphasized;
}

class _InfoRowView extends StatelessWidget {
  const _InfoRowView({required this.row});

  final _InfoRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            row.label,
            style: TextStyle(
              fontSize: FontSize.s13,
              color: ColorManager.colorGrey6,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: row.emphasized ? FontSize.s17 : FontSize.s15,
                fontWeight: row.emphasized ? FontWeight.w500 : FontWeight.w400,
                color: ColorManager.colorFontPrimary,
              ),
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
          _SectionTitle(title: "booking_details_section_rating".tr),
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
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: FontSize.s14,
        fontWeight: FontWeight.w600,
        color: ColorManager.colorFontPrimary,
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
          _SectionTitle(title: "booking_details_section_pickup".tr),
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
