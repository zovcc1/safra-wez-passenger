import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/dto/pickup_dto.dart';
import 'package:safraa_passenger_app/data/dto/trip_search_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/data/models/trip_search_result_model.dart';
import 'package:safraa_passenger_app/data/repos/bookings_repo.dart';
import 'package:safraa_passenger_app/data/repos/trips_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/pages/booking_details_page/collection_point_sheet.dart';
import 'package:safraa_passenger_app/presentation/pages/booking_rating_sheet/booking_rating_sheet.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class BookingDetailsPageController extends GetxController {
  final BookingsRepo bookingsRepo = Get.find<BookingsRepo>();
  final TripsRepo tripsRepo = Get.find<TripsRepo>();

  late final int bookingId;
  bool _openRatingOnLoad = false;

  final loadingState = LoadingState.idle.obs;
  final Rxn<BookingModel> booking = Rxn<BookingModel>();
  final changingPickup = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    bookingId = args is Map ? (args["bookingId"] as int) : 0;
    _openRatingOnLoad = args is Map && args["openRating"] == true;
    _load();
  }

  Future<void> _load() async {
    loadingState.value = LoadingState.loading;
    final response = await bookingsRepo.details(bookingId);
    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      return;
    }
    booking.value = response.data;
    loadingState.value = LoadingState.doneWithData;
    // إشعار rating_prompt يفتح ورقة التقييم مباشرة، إن كان التقييم ممكنًا.
    if (_openRatingOnLoad && response.data!.canRate) {
      _openRatingOnLoad = false;
      openRating();
    }
  }

  Future<void> retry() => _load();

  /// نتيجة التقييم تعيد الحجز كاملًا (can_rate=false و rating معبّأ)، فنستبدله
  /// مباشرة بدون طلب إضافي.
  Future<void> openRating() async {
    final updated = await BookingRatingSheet.show(bookingId);
    if (updated != null) booking.value = updated;
  }

  void fileComplaint() => Get.toNamed(
    AppRoutes.fileComplaintRoute,
    arguments: {"bookingId": bookingId},
  );

  void openTracking() =>
      Get.toNamed(AppRoutes.trackingRoute, arguments: {"bookingId": bookingId});

  /// زر تغيير النقطة يظهر فقط لحجز بنقطة ركوب وحالته تسمح؛ نافذة الـ 30 دقيقة
  /// والمنطقة يحكم بهما الخادم (422).
  bool get canChangePickup {
    final b = booking.value;
    if (b == null || b.pickup == null) return false;
    if (b.status != "confirmed" && b.status != "pending_confirmation") {
      return false;
    }
    final departure = b.journey?.departureTime;
    return departure == null || departure.isAfter(DateTime.now());
  }

  bool get canTrack {
    final b = booking.value;
    if (b == null || b.pickup == null) return false;
    final tripStatus = b.journey?.status;
    return (tripStatus == "waiting" || tripStatus == "departed") &&
        (b.status == "confirmed" || b.status == "boarded");
  }

  Future<void> changePickup() async {
    final current = booking.value;
    final pickup = current?.pickup;
    if (current == null || pickup == null || changingPickup.value) return;

    changingPickup.value = true;
    // ردّ الحجز لا يحمل نقاط الرحلة ولا start_point (بالبحث فقط)، فنجلب الرحلة
    // من البحث حسب المسار واليوم.
    final trip = await _findTrip(current);
    changingPickup.value = false;

    PickupDto? dto;
    if (pickup.isCollectionPoint) {
      if (trip == null || trip.collectionPoints.isEmpty) {
        CustomToasts(
          message: "booking_pickup_points_unavailable".tr,
          type: CustomToastType.error,
        ).show();
        return;
      }
      dto = await CollectionPointSheet.show(
        trip.collectionPoints,
        currentId: pickup.collectionPointId,
      );
    } else {
      final picked = await Get.toNamed(
        AppRoutes.pickupPickerRoute,
        arguments: {
          "startPoint": trip?.startPoint,
          "endPoint": trip?.endPoint,
          "allowRoutePickup": trip?.allowRoutePickup ?? false,
          "initial": pickup,
        },
      );
      if (picked is PickupDto) dto = picked;
    }
    if (dto == null) return;

    changingPickup.value = true;
    final response = await bookingsRepo.changePickup(bookingId, dto);
    changingPickup.value = false;

    if (!response.success) {
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }
    CustomToasts(
      message: "booking_pickup_changed".tr,
      type: CustomToastType.success,
    ).show();
    await _load();
  }

  Future<TripSearchResultModel?> _findTrip(BookingModel b) async {
    final route = b.journey?.route;
    final departure = b.journey?.departureTime;
    final tripId = b.tripId;
    if (route?.origin == null || route?.destination == null) return null;
    if (departure == null || tripId == null) return null;

    final day = departure.toLocal();
    String? cursor;
    for (var page = 0; page < 5; page++) {
      final response = await tripsRepo.search(
        TripSearchDto(
          originGovernorateId: route!.origin!.governorateId,
          destinationGovernorateId: route.destination!.governorateId,
          departureDateFrom: day.subtract(const Duration(days: 1)),
          departureDateTo: day.add(const Duration(days: 1)),
          includeOpenTrips: false,
          cursor: cursor,
        ),
      );
      if (!response.success || response.data == null) return null;
      for (final item in response.data!.items) {
        if (!item.isOpenTrip && item.id == tripId) return item;
      }
      cursor = response.data!.nextCursor;
      if (!response.data!.hasMore || cursor == null) return null;
    }
    return null;
  }
}
