import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// أنواع الحركة الثمانية ثابتة بالكود؛ الترجمة على التطبيق لا الخادم.
class WalletTypeDisplay {
  final String label;
  final IconData icon;
  final Color color;

  const WalletTypeDisplay(this.label, this.icon, this.color);

  static const List<String> allTypes = [
    "charge",
    "deduct",
    "refund",
    "freeze_hold",
    "unfreeze_release",
    "settle",
    "commission_deduct",
    "payout",
  ];

  static WalletTypeDisplay of(String type) {
    switch (type) {
      case "charge":
        return WalletTypeDisplay(
          "wallet_type_charge".tr,
          Icons.add_card_outlined,
          ColorManager.colorGreen3,
        );
      case "deduct":
        return WalletTypeDisplay(
          "wallet_type_deduct".tr,
          Icons.remove_circle_outline,
          ColorManager.colorError300,
        );
      case "refund":
        return WalletTypeDisplay(
          "wallet_type_refund".tr,
          Icons.replay_outlined,
          ColorManager.colorGreen3,
        );
      case "freeze_hold":
        return WalletTypeDisplay(
          "wallet_type_freeze_hold".tr,
          Icons.lock_clock_outlined,
          ColorManager.colorOrange,
        );
      case "unfreeze_release":
        return WalletTypeDisplay(
          "wallet_type_unfreeze_release".tr,
          Icons.lock_open_outlined,
          ColorManager.colorPrimary,
        );
      case "settle":
        return WalletTypeDisplay(
          "wallet_type_settle".tr,
          Icons.receipt_long_outlined,
          ColorManager.colorError300,
        );
      case "commission_deduct":
        return WalletTypeDisplay(
          "wallet_type_commission_deduct".tr,
          Icons.percent_outlined,
          ColorManager.colorError300,
        );
      case "payout":
        return WalletTypeDisplay(
          "wallet_type_payout".tr,
          Icons.payments_outlined,
          ColorManager.colorError300,
        );
      default:
        return WalletTypeDisplay(
          type,
          Icons.swap_horiz,
          ColorManager.colorGrey6,
        );
    }
  }

  /// credit → +، debit → −، hold/release لا يغيّران الإجمالي فلا إشارة.
  static String signOf(String direction) {
    switch (direction) {
      case "credit":
        return "+";
      case "debit":
        return "-";
      default:
        return "";
    }
  }

  static String referenceLabel(String type) {
    switch (type) {
      case "booking":
        return "wallet_ref_booking".tr;
      case "visa":
        return "wallet_ref_visa".tr;
      case "commission":
        return "wallet_ref_commission".tr;
      case "payout":
        return "wallet_ref_payout".tr;
      case "manual":
        return "wallet_ref_manual".tr;
      case "handoff_reward":
        return "wallet_ref_handoff_reward".tr;
      default:
        return type;
    }
  }
}
