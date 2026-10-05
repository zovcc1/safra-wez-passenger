import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/complaint_notification_router.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

/// توجيه إشعارات المسافر عند الضغط عليها (صندوق الوارد أو FCM) حسب `type` و
/// `data`. يرجّع true إذا وُجّه الإشعار؛ false يعني "لا وجهة" فيبقى المستخدم
/// بالصندوق (قد يشير الإشعار لشيء محذوف، أو لنوع بلا شاشة).
abstract class NotificationRouter {
  static const Set<String> _tracking = {
    "pickup_started",
    "pickup_eta_update",
    "pickup_driver_near",
    "pickup_driver_arrived",
  };

  static const Set<String> _paymentRequest = {
    "payment_request_created",
    "payment_request_expired",
    "payment_request_cancelled",
    "payment_request_trip_cancelled",
    "payment_request_trip_handed_off",
  };

  /// أنواع تفتح الحجز عبر data.booking_id.
  static const Set<String> _booking = {
    "pickup_point_remapped",
    "open_trip_expired",
    "trip_cancelled",
    "trip_cancelled_refunded",
    "trip_cancelled_after_boarding",
    "handoff_transferred",
    "handoff_refunded",
    "handoff_cheaper_cash",
    "handoff_seats_split",
    "handoff_escalated",
    "handoff_cancelled",
    "booking_confirmed",
    "booking_no_show",
    "booking_cancelled",
    "trip_started",
    "open_trip_vehicle_changed",
    "open_trip_promoted",
    "booking_promotion_failed",
    "rating_comment_hidden",
    "rating_comment_restored",
    "departure_reminder",
  };

  static bool open(String type, Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};

    if (ComplaintNotificationRouter.handles(type)) {
      return ComplaintNotificationRouter.open(type, d);
    }

    if (_tracking.contains(type)) {
      final bookingId = _int(d["booking_id"]);
      if (bookingId == null) return false;
      Get.toNamed(AppRoutes.trackingRoute, arguments: {"bookingId": bookingId});
      return true;
    }

    if (_paymentRequest.contains(type)) {
      final id = _int(d["payment_request_id"]);
      if (id == null) return false;
      Get.toNamed(
        AppRoutes.paymentRequestDetailsRoute,
        arguments: {"paymentRequestId": id},
      );
      return true;
    }

    if (type.startsWith("visa_request_")) {
      final id = _int(d["request_id"]);
      if (id == null) return false;
      Get.toNamed(
        AppRoutes.visaRequestDetailsRoute,
        arguments: {"requestId": id},
      );
      return true;
    }

    if (type == "wallet_topped_up") {
      Get.toNamed(AppRoutes.walletRoute);
      return true;
    }

    if (_booking.contains(type) || type == "rating_prompt") {
      final bookingId = _int(d["booking_id"]);
      if (bookingId == null) return false;
      Get.toNamed(
        AppRoutes.bookingDetailsRoute,
        arguments: {
          "bookingId": bookingId,
          "openRating": type == "rating_prompt",
        },
      );
      return true;
    }

    // trip_departure_changed / trip_vehicle_changed: الحمولة trip_id فقط بلا
    // booking_id، campaign_*: الهدف غير موثّق، notification_test: الصندوق.
    return false;
  }

  static int? _int(dynamic v) => v is int ? v : int.tryParse("$v");
}
