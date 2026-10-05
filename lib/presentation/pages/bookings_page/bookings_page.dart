import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/info_pill.dart';
import 'package:safraa_passenger_app/presentation/pages/bookings_page/bookings_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/booking_status_display.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class BookingsPage extends GetView<BookingsPageController> {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.reload,
          child: Obx(() => _body()),
        ),
      ),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle || state == LoadingState.loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Center(
              child: FadeSlideIn(
                offset: 8,
                child: SpinKitFadingCircle(
                  color: ColorManager.colorPrimary,
                  size: 42,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (state == LoadingState.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: FadeSlideIn(
              child: ErrorPlaceholderWidget(title: "bookings_error_title".tr),
            ),
          ),
        ],
      );
    }

    if (state == LoadingState.doneWithNoData) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: FadeSlideIn(
              child: EmptyStateWidget(
                icon: Icons.event_seat_outlined,
                title: "bookings_empty_title".tr,
                subtitle: "bookings_empty_subtitle".tr,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      itemCount:
          controller.bookings.length + (controller.loadingMore.value ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p12),
      itemBuilder: (context, index) {
        if (index >= controller.bookings.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p16),
            child: Center(
              child: SpinKitThreeBounce(
                color: ColorManager.colorPrimary,
                size: 20,
              ),
            ),
          );
        }
        return FadeSlideIn(
          delay: Duration(milliseconds: 40 * index.clamp(0, 8)),
          child: _BookingCard(booking: controller.bookings[index]),
        );
      },
    );
  }
}

class _BookingCard extends StatefulWidget {
  const _BookingCard({required this.booking});

  final BookingModel booking;

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final status = BookingStatusDisplay.of(booking.status);
    final journey = booking.journey;
    final isOpenTrip = journey?.isOpenTrip == true;
    final dateLabel = isOpenTrip ? journey?.expiresAt : journey?.departureTime;
    final timeText = (isOpenTrip ? "trips_expires_at" : "trips_departure_at")
        .trParams({
          "date": DateConverter.dateToStringAR(dateLabel),
          "time": DateConverter.timeUTCToString(dateLabel),
        });

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
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
              borderRadius: BorderRadius.circular(AppSize.s16),
              onTap: () => Get.toNamed(
                AppRoutes.bookingDetailsRoute,
                arguments: {"bookingId": booking.bookingId},
              ),
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
                          Icons.route_outlined,
                          size: AppSize.s20,
                          color: ColorManager.colorPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            journey?.route?.displayName ??
                                "bookings_fallback_title".trParams({
                                  "id": "${booking.bookingId}",
                                }),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: FontSize.s15,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.colorFontPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppPadding.p8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.label,
                            style: TextStyle(
                              fontSize: FontSize.s10_5,
                              fontWeight: FontWeight.bold,
                              color: status.color,
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
                          text: "bookings_seats_count".trParams({
                            "count": "${booking.seatsCount}",
                          }),
                        ),
                        InfoPill(
                          icon: isOpenTrip
                              ? Icons.hourglass_bottom_outlined
                              : Icons.schedule_outlined,
                          text: timeText,
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
                        Expanded(
                          child: Text(
                            "#${booking.bookingId}",
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.colorGrey6,
                            ),
                          ),
                        ),
                        Text(
                          "${booking.totalAmount} ${booking.currency}",
                          style: TextStyle(
                            fontSize: FontSize.s16,
                            fontWeight: FontWeight.bold,
                            color: ColorManager.colorPrimary,
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
        ),
      ),
    );
  }
}
