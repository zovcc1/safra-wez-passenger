import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// دورة حياة طلب التأشيرة:
/// submitted → under_review → assigned → approved → delivered
///                                  ↘ needs_info / rejected / withdrawn / cancelled
/// ملاحظة: cancelled ورفض rejected مختلفان بالمعنى (الأول إلغاء بطلب الراكب
/// عبر الدعم، الثاني رفض من السفارة) لذا لهما لونان مختلفان ولا تُعرض بطاقة
/// admin_note على الإطلاق لـ cancelled (راجع تفاصيل الشاشة).
class VisaStatusDisplay {
  final String label;
  final Color color;

  const VisaStatusDisplay(this.label, this.color);

  /// اسم طريقة الدفع المعروض (external, wallet, ...).
  static String paymentLabel(String method) => switch (method) {
    "external" => "visa_payment_external".tr,
    "wallet" => "create_booking_payment_wallet_short".tr,
    "cash_on_delivery" => "create_booking_payment_cod_short".tr,
    _ => method,
  };

  static VisaStatusDisplay of(String status) {
    switch (status) {
      case "submitted":
        return VisaStatusDisplay(
          "visa_status_submitted".tr,
          ColorManager.colorGrey6,
        );
      case "under_review":
        return VisaStatusDisplay(
          "visa_status_under_review".tr,
          ColorManager.colorOrange,
        );
      case "assigned":
        return VisaStatusDisplay(
          "visa_status_assigned".tr,
          ColorManager.colorOrange,
        );
      case "approved":
        return VisaStatusDisplay(
          "visa_status_approved".tr,
          ColorManager.colorGreen3,
        );
      case "delivered":
        return VisaStatusDisplay(
          "visa_status_delivered".tr,
          ColorManager.colorPrimary,
        );
      case "needs_info":
        return VisaStatusDisplay(
          "visa_status_needs_info".tr,
          ColorManager.colorOrange,
        );
      case "rejected":
        return VisaStatusDisplay(
          "visa_status_rejected".tr,
          ColorManager.colorError300,
        );
      case "withdrawn":
        return VisaStatusDisplay(
          "visa_status_withdrawn".tr,
          ColorManager.colorGrey6,
        );
      case "cancelled":
        return VisaStatusDisplay(
          "visa_status_cancelled".tr,
          ColorManager.colorGrey6,
        );
      default:
        return VisaStatusDisplay(status, ColorManager.colorGrey6);
    }
  }
}
