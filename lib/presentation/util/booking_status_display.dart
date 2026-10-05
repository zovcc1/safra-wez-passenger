import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// المواصفات لا تُعدّد كل قيم status الممكنة للحجز بشكل صريح، فهذه تغطي
/// الشائع منها مع fallback يعرض القيمة الخام لأي حالة غير متوقعة بدل كسر
/// الواجهة.
class BookingStatusDisplay {
  final String label;
  final Color color;

  const BookingStatusDisplay(this.label, this.color);

  static BookingStatusDisplay of(String status) {
    switch (status) {
      case "confirmed":
        return BookingStatusDisplay(
          "booking_status_confirmed".tr,
          ColorManager.colorGreen3,
        );
      case "pending":
        return BookingStatusDisplay(
          "booking_status_pending".tr,
          ColorManager.colorOrange,
        );
      case "cancelled":
        return BookingStatusDisplay(
          "booking_status_cancelled".tr,
          ColorManager.colorError300,
        );
      case "completed":
        return BookingStatusDisplay(
          "booking_status_completed".tr,
          ColorManager.colorPrimary,
        );
      case "boarded":
        return BookingStatusDisplay(
          "booking_status_boarded".tr,
          ColorManager.colorGreen3,
        );
      case "no_show":
        return BookingStatusDisplay(
          "booking_status_no_show".tr,
          ColorManager.colorError300,
        );
      default:
        return BookingStatusDisplay(status, ColorManager.colorGrey6);
    }
  }
}
