import 'dart:async';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    _eventsSub = realtime.events.stream.listen(_onEvent);
    // كل deploy يقطع الـ sockets ولا يُعاد إرسال ما فات → لقطة جديدة.
    _reconnectSub = realtime.reconnected.stream.listen((_) => _loadSnapshot());
    _load();
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
