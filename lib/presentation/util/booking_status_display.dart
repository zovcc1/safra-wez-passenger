import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// المواصفات لا تُعدّد كل قيم status الممكنة للحجز بشكل صريح، فهذه تغطي
/// الشائع منها مع fallback يعرض القيمة الخام لأي حالة غير متوقعة بدل كسر
/// الواجهة.
class BookingStatusDisplay {
  final String label;
  final Color color;
  final String? description;

  const BookingStatusDisplay(this.label, this.color, [this.description]);

  static BookingStatusDisplay of(String status) {
    switch (status) {
      case "confirmed":
        return BookingStatusDisplay(
          "booking_status_confirmed".tr,
          ColorManager.colorGreen3,
          "booking_status_confirmed_desc".tr,
        );
      case "pending":
        return BookingStatusDisplay(
          "booking_status_pending".tr,
          ColorManager.colorOrange,
          "booking_status_pending_desc".tr,
        );
      case "cancelled":
        return BookingStatusDisplay(
          "booking_status_cancelled".tr,
          ColorManager.colorError300,
          "booking_status_cancelled_desc".tr,
        );
      case "completed":
        return BookingStatusDisplay(
          "booking_status_completed".tr,
          ColorManager.colorPrimary,
          "booking_status_completed_desc".tr,
        );
      case "boarded":
        return BookingStatusDisplay(
          "booking_status_boarded".tr,
          ColorManager.colorGreen3,
          "booking_status_boarded_desc".tr,
        );
      case "no_show":
        return BookingStatusDisplay(
          "booking_status_no_show".tr,
          ColorManager.colorError300,
          "booking_status_no_show_desc".tr,
        );
      default:
        return BookingStatusDisplay(status, ColorManager.colorGrey6);
    }
  }
}
