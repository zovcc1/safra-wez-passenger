import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

class ComplaintStatusDisplay {
  final String label;
  final Color color;

  const ComplaintStatusDisplay(this.label, this.color);

  static ComplaintStatusDisplay of(String status) {
    switch (status) {
      case "open":
        return ComplaintStatusDisplay(
          "complaint_status_open".tr,
          ColorManager.colorGrey6,
        );
      case "in_progress":
        return ComplaintStatusDisplay(
          "complaint_status_in_progress".tr,
          ColorManager.colorPrimary,
        );
      case "awaiting_passenger":
        return ComplaintStatusDisplay(
          "complaint_status_awaiting_passenger".tr,
          ColorManager.colorOrange,
        );
      case "resolved":
        return ComplaintStatusDisplay(
          "complaint_status_resolved".tr,
          ColorManager.colorGreen3,
        );
      case "rejected":
        return ComplaintStatusDisplay(
          "complaint_status_rejected".tr,
          ColorManager.colorError300,
        );
      default:
        // حالة مستقبلية مجهولة: النص الخام بـ chip محايد.
        return ComplaintStatusDisplay(status, ColorManager.colorGrey6);
    }
  }
}

IconData complaintCategoryIcon(String key) => switch (key) {
  "driver_behavior" => Icons.person_outline_rounded,
  "vehicle_condition" => Icons.directions_car_outlined,
  "delay" => Icons.schedule_outlined,
  "trip_cancelled" => Icons.cancel_outlined,
  "pricing_payment" => Icons.payments_outlined,
  "lost_item" => Icons.inventory_2_outlined,
  "app_issue" => Icons.phone_android_outlined,
  "other" => Icons.more_horiz_rounded,
  _ => Icons.help_outline_rounded,
};
