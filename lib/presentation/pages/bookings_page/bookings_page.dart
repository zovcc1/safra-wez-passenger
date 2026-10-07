import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/pages/bookings_page/bookings_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/booking_status_display.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class BookingsPage extends GetView<BookingsPageController> {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
      return const AppPageLoader();
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
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p8),
      itemBuilder: (context, index) {
        if (index >= controller.bookings.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p16),
            child: Center(child: AppLoader.dots(size: 20)),
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final status = BookingStatusDisplay.of(booking.status);
    final journey = booking.journey;
    final isOpenTrip = journey?.isOpenTrip == true;
    final eventTime = isOpenTrip ? journey?.expiresAt : journey?.departureTime;
    final dateText = DateConverter.dateToStringAR(eventTime);
    final timeText = DateConverter.timeUTCToString(eventTime);

    return TripCardShell(
      onTap: () => Get.toNamed(
        AppRoutes.bookingDetailsRoute,
        arguments: {"bookingId": booking.bookingId},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCardHeader(
            title:
                journey?.route?.displayName ??
                "bookings_fallback_title".trParams({
                  "id": "${booking.bookingId}",
                }),
            badge: status.label,
            badgeColor: status.color,
          ),
          const SizedBox(height: 8),
          TripInfoBox(
            start: TripInfoItem(
              icon: isOpenTrip
                  ? Icons.hourglass_bottom_rounded
                  : Icons.calendar_today_outlined,
              title: isOpenTrip
                  ? "trips_expires_at"
                        .trParams({"date": dateText, "time": ""})
                        .trim()
                  : dateText,
              subtitle: timeText,
            ),
            end: TripInfoItem(
              icon: Icons.event_seat_outlined,
              title: "trips_seats_available_short".trParams({
                "seats": "${booking.seatsCount}",
              }),
            ),
          ),
          const SizedBox(height: 6),
          TripCardFooter(price: Money.format(booking.totalAmount)),
        ],
      ),
    );
  }
}
