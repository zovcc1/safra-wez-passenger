import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/dto/create_booking_dto.dart';
import 'package:safraa_passenger_app/data/dto/pickup_dto.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/trip_search_result_model.dart';
import 'package:safraa_passenger_app/data/models/trip_seat_model.dart';
import 'package:safraa_passenger_app/data/repos/bookings_repo.dart';
import 'package:safraa_passenger_app/data/repos/trips_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/idempotency_key.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class CreateBookingPageController extends GetxController {
  final BookingsRepo bookingsRepo = Get.find<BookingsRepo>();
  final TripsRepo tripsRepo = Get.find<TripsRepo>();

  late final TripSearchResultModel result;

  // رحلة مفتوحة: عدد فقط. رحلة مجدولة: اختيار مقاعد فردية عبر seats/selectedSeatIds.
  final seatsCount = 1.obs;
  final seatsLoadingState = LoadingState.idle.obs;
  final seats = <TripSeatModel>[].obs;
  final selectedSeatIds = <int>{}.obs;

  // TR1: نقطة الركوب. collection_points => collectionPointId، door_to_door =>
  // pickup (gps/pin) من شاشة الخريطة.
  final selectedCollectionPointId = RxnInt();
  final Rxn<PickupDto> pickup = Rxn<PickupDto>();

  final paymentMethod = Rxn<String>();
  final submitting = false.obs;

  // يُولَّد مرة واحدة لكل محاولة حجز ويُعاد استخدامه عند إعادة المحاولة بعد
  // فشل شبكي (راجع القسم 9.1) — وليس عند فتح شاشة حجز جديدة.
  late final String _idempotencyKey;

  @override
  void onInit() {
    super.onInit();
    result = Get.arguments as TripSearchResultModel;
    _idempotencyKey = generateIdempotencyKey();
    if (!result.isOpenTrip) {
      _loadSeats();
    }
  }

  Future<void> _loadSeats() async {
    seatsLoadingState.value = LoadingState.loading;
    final response = await tripsRepo.seats(result.id);
    if (!response.success) {
      seatsLoadingState.value = LoadingState.hasError;
      return;
    }
    seats.assignAll(response.data ?? []);
    seatsLoadingState.value = seats.isEmpty
        ? LoadingState.doneWithNoData
        : LoadingState.doneWithData;
  }

  void retryLoadSeats() => _loadSeats();

  Future<void> refreshSeats() async {
    if (!result.isOpenTrip) await _loadSeats();
  }

  void toggleSeat(TripSeatModel seat) {
    if (!seat.isAvailable) return;
    if (selectedSeatIds.contains(seat.tripSeatId)) {
      selectedSeatIds.remove(seat.tripSeatId);
    } else {
      selectedSeatIds.add(seat.tripSeatId);
    }
  }

  void setSeatsCount(int value) {
    if (value < 1 || value > result.availableSeats) return;
    seatsCount.value = value;
  }

  PickupMode get pickupMode =>
      result.isOpenTrip ? PickupMode.fixedPoint : result.pickupMode;

  void selectCollectionPoint(int id) => selectedCollectionPointId.value = id;

  Future<void> pickOnMap() async {
    final picked = await Get.toNamed(
      AppRoutes.pickupPickerRoute,
      arguments: {
        "startPoint": result.startPoint,
        "endPoint": result.endPoint,
        "allowRoutePickup": result.allowRoutePickup,
      },
    );
    if (picked is PickupDto) pickup.value = picked;
  }

  PickupDto? _buildPickup() {
    switch (pickupMode) {
      case PickupMode.collectionPoints:
        final id = selectedCollectionPointId.value;
        return id == null ? null : PickupDto.collectionPoint(id);
      case PickupMode.doorToDoor:
        return pickup.value;
      case PickupMode.fixedPoint:
        return null;
    }
  }

  void setPaymentMethod(String method) => paymentMethod.value = method;

  int get selectedSeatsQuantity =>
      result.isOpenTrip ? seatsCount.value : selectedSeatIds.length;

  Future<void> submit() async {
    if (paymentMethod.value == null) {
      CustomToasts(
        message: "create_booking_validation_payment_method".tr,
        type: CustomToastType.warning,
      ).show();
      return;
    }
    if (!result.isOpenTrip && selectedSeatIds.isEmpty) {
      CustomToasts(
        message: "create_booking_validation_seat_required".tr,
        type: CustomToastType.warning,
      ).show();
      return;
    }

    final pickupDto = _buildPickup();
    if (pickupMode != PickupMode.fixedPoint && pickupDto == null) {
      CustomToasts(
        message: "create_booking_validation_pickup_required".tr,
        type: CustomToastType.warning,
      ).show();
      return;
    }

    submitting.value = true;
    final dto = result.isOpenTrip
        ? CreateBookingDto.openTrip(
            openTripId: result.id,
            seatsCount: seatsCount.value,
            paymentMethod: paymentMethod.value!,
            idempotencyKey: _idempotencyKey,
          )
        : CreateBookingDto.scheduledTrip(
            tripId: result.id,
            tripSeatIds: selectedSeatIds.toList(),
            paymentMethod: paymentMethod.value!,
            idempotencyKey: _idempotencyKey,
            pickup: pickupDto,
          );
    final response = await bookingsRepo.create(dto);
    submitting.value = false;

    if (!response.success) {
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      // مقعد حُجز للتو من مستخدم آخر (409) — أعِد تحميل قائمة المقاعد كي لا
      // يحاول الراكب إعادة إرسال نفس المقعد المحجوز.
      if (!result.isOpenTrip) _loadSeats();
      return;
    }

    CustomToasts(
      message: "create_booking_success".tr,
      type: CustomToastType.success,
    ).show();
    Get.offNamed(
      AppRoutes.bookingDetailsRoute,
      arguments: {"bookingId": response.data!.bookingId},
    );
  }
}
