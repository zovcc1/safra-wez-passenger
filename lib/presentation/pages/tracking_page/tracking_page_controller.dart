import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' show Colors, Icons;
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/map_marker_builder.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safraa_passenger_app/core/services/directions_service.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/core/services/realtime_service.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/data/repos/bookings_repo.dart';

/// شاشة التتبع: لقطة REST عند الفتح وبعد كل إعادة اتصال، ثم تحديثات الـ socket.
/// الراكب لا يرى موقع أو ETA راكب آخر؛ نفلتر أحداث القناة الخاصة بـ booking_id.
class TrackingPageController extends GetxController {
  final BookingsRepo bookingsRepo = Get.find<BookingsRepo>();
  final RealtimeService realtime = Get.find<RealtimeService>();
  final CacheService cache = Get.find<CacheService>();

  late final int bookingId;

  final loadingState = LoadingState.idle.obs;
  final snapshot = Rxn<TrackingSnapshotModel>();
  final booking = Rxn<BookingModel>();
  final position = Rxn<TrackingPositionModel>();
  final etaMinutes = RxnInt();
  final etaComputedAt = Rxn<DateTime>();
  final stopArrivedAt = Rxn<DateTime>();

  /// سبب انتهاء التتبع (completed | cancelled | booking_cancelled | no_show |
  /// handed_off) أو null إن كان جاريًا.
  final endedReason = RxnString();

  final driverIcon = Rxn<BitmapDescriptor>();
  final passengerIcon = Rxn<BitmapDescriptor>();

  /// المسار المتوقع من موقع السائق إلى نقطة الصعود.
  final routePoints = <LatLng>[].obs;

  /// true = خط مستقيم احتياطي لأن Directions غير متاح.
  final routeIsApproximate = false.obs;
  LatLng? _routeOrigin;
  DateTime? _routeFetchedAt;
  bool _routeLoading = false;

  GoogleMapController? mapController;
  StreamSubscription<RealtimeEvent>? _eventsSub;
  StreamSubscription<void>? _reconnectSub;
  String? _tripChannel;
  String? _passengerChannel;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    bookingId = args is Map ? (args["bookingId"] as int) : 0;
    _loadMarkerIcons();
    _eventsSub = realtime.events.stream.listen(_onEvent);
    // كل deploy يقطع الـ sockets ولا يُعاد إرسال ما فات → لقطة جديدة.
    _reconnectSub = realtime.reconnected.stream.listen((_) => _loadSnapshot());
    _load();
  }

  Future<void> _loadMarkerIcons() async {
    driverIcon.value = await MapMarkerBuilder.build(
      icon: Icons.directions_car,
      label: "tracking_driver_label".tr,
      color: ColorManager.colorPrimary,
    );
    passengerIcon.value = await MapMarkerBuilder.build(
      icon: Icons.person,
      label: "tracking_you_label".tr,
      color: Colors.green.shade700,
    );
  }

  Future<void> _load() async {
    loadingState.value = LoadingState.loading;
    final results = await Future.wait([
      bookingsRepo.tracking(bookingId),
      bookingsRepo.details(bookingId),
    ]);
    final tracking = results[0];
    if (!tracking.success) {
      loadingState.value = LoadingState.hasError;
      return;
    }
    if (results[1].success) {
      booking.value = results[1].data as BookingModel?;
    }
    _applySnapshot(tracking.data as TrackingSnapshotModel);
    loadingState.value = LoadingState.doneWithData;
    await _subscribe();
  }

  Future<void> _loadSnapshot() async {
    final response = await bookingsRepo.tracking(bookingId);
    if (response.success) _applySnapshot(response.data!);
  }

  Future<void> refreshAll() => _load();

  void _applySnapshot(TrackingSnapshotModel s) {
    snapshot.value = s;
    position.value = s.position;
    etaMinutes.value = s.etaMinutes;
    etaComputedAt.value = s.etaComputedAt;
    stopArrivedAt.value = s.stopArrivedAt;
    if (s.tripStatus == "completed" || s.tripStatus == "cancelled") {
      endedReason.value = s.tripStatus;
    } else if (s.bookingStatus == "boarded") {
      endedReason.value = "boarded";
    }
    _followVehicle();
  }

  /// الاشتراك ممكن فقط والرحلة waiting أو departed، والتفويض عند الاشتراك فقط.
  Future<void> _subscribe() async {
    final s = snapshot.value;
    if (s == null || endedReason.value != null) return;
    if (s.tripStatus != "waiting" && s.tripStatus != "departed") return;
    if (!realtime.isConfigured) return;

    final userId = cache.getUser()?.userId;
    _tripChannel = "trip.${s.tripId}.location";
    await realtime.subscribe(_tripChannel!);
    if (userId != null) {
      _passengerChannel = "passenger.$userId";
      await realtime.subscribe(_passengerChannel!);
    }
  }

  void _onEvent(RealtimeEvent e) {
    final isTripChannel =
        _tripChannel != null && e.channel == "private-$_tripChannel";
    final isPassengerChannel =
        _passengerChannel != null && e.channel == "private-$_passengerChannel";
    if (!isTripChannel && !isPassengerChannel) return;

    final tripId = snapshot.value?.tripId;
    if (e.data["trip_id"] != null && e.data["trip_id"] != tripId) return;
    // أحداث القناة الخاصة تخص حجزًا بعينه (قد يكون للراكب أكثر من حجز).
    if (isPassengerChannel &&
        e.data["booking_id"] != null &&
        e.data["booking_id"] != bookingId) {
      return;
    }

    switch (e.event) {
      case "tracking.position":
        final p = TrackingPositionModel.tryParse(e.data);
        if (p == null) return;
        position.value = p;
        _followVehicle();
      case "pickup.eta":
        etaMinutes.value = e.data["eta_minutes"];
        etaComputedAt.value = DateTime.tryParse("${e.data["computed_at"]}");
      case "pickup.stop_updated":
        stopArrivedAt.value = DateTime.tryParse("${e.data["arrived_at"]}");
        // الوصول يغيّر ETA وترتيب المحطات؛ اللقطة أضمن من التخمين.
        _loadSnapshot();
      case "tracking.ended":
        endedReason.value = "${e.data["reason"]}";
        _unsubscribeAll();
    }
  }

  void _followVehicle() {
    final p = position.value;
    if (p == null) return;
    mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(p.latitude, p.longitude)),
    );
    _updateRoute(p);
  }

  /// أفضل مسار (أسرع بديل) من موقع السائق إلى نقطة الصعود. نعيد الطلب فقط إذا
  /// تحرك السائق أكثر من 150م أو مرت دقيقة، لتخفيف استهلاك Directions.
  Future<void> _updateRoute(TrackingPositionModel p) async {
    final pickup = booking.value?.pickup;
    if (pickup == null || !pickup.hasCoordinates || endedReason.value != null) {
      return;
    }
    final origin = LatLng(p.latitude, p.longitude);
    final last = _routeOrigin;
    if (_routeLoading) return;
    if (last != null &&
        DateTime.now().difference(_routeFetchedAt!) <
            const Duration(minutes: 1) &&
        _distanceMeters(last, origin) < 150) {
      return;
    }
    _routeLoading = true;
    try {
      final destination = LatLng(pickup.latitude!, pickup.longitude!);
      final routes = await DirectionsService.fetch(origin, destination);
      _routeOrigin = origin;
      _routeFetchedAt = DateTime.now();
      // عند فشل Directions نرسم خطًا مباشرًا بين النقطتين بدل ترك الخريطة بلا مسار.
      final points = routes.isEmpty
          ? [origin, destination]
          : routes
                .reduce(
                  (a, b) => a.durationSeconds <= b.durationSeconds ? a : b,
                )
                .points;
      final first = routePoints.isEmpty;
      routeIsApproximate.value = routes.isEmpty;
      routePoints.assignAll(points);
      if (first) _fitRoute(origin, destination);
    } finally {
      _routeLoading = false;
    }
  }

  /// يظهر السائق ونقطة الصعود معًا عند أول رسم للمسار.
  void _fitRoute(LatLng a, LatLng b) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(a.latitude, b.latitude),
        math.min(a.longitude, b.longitude),
      ),
      northeast: LatLng(
        math.max(a.latitude, b.latitude),
        math.max(a.longitude, b.longitude),
      ),
    );
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  static double _distanceMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(a.latitude * math.pi / 180) *
            math.cos(b.latitude * math.pi / 180) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  /// عمر آخر تحديث بالدقائق (للعرض "آخر تحديث"). ETA عمره دقائق = قديم لا خاطئ.
  DateTime? get lastUpdate => position.value?.recordedAt ?? etaComputedAt.value;

  void _unsubscribeAll() {
    if (_tripChannel != null) realtime.unsubscribe(_tripChannel!);
    if (_passengerChannel != null) realtime.unsubscribe(_passengerChannel!);
    _tripChannel = null;
    _passengerChannel = null;
  }

  @override
  void onClose() {
    _eventsSub?.cancel();
    _reconnectSub?.cancel();
    _unsubscribeAll();
    mapController?.dispose();
    super.onClose();
  }
}
