import 'package:flutter/material.dart';

abstract class ColorManager {
  /// يُحدَّث من [ThemeController] عند تبديل المود. لا تُعدّل هذه القيمة مباشرة.
  static bool isDark = false;

  // اللون الأساسي للهوية البصرية الجديدة
  static Color get colorPrimary => const Color(0xFF0030FF);
  static Color get colorPrimary1 => colorPrimary;
  static const Color colorPrimary2 = Color(0xff4F90DA);
  static Color get colorSecondary => const Color(0xFFFFFFFF);
  static const Color colorSecondary2 = Color(0xff0F172A);

  /// خلفية شاشة السبلاش - تتبع اللون الثانوي للهوية البصرية
  static Color get colorSplashBackground => colorSecondary;

  static const Color colorSecondaryRed = Color(0xFFE94B3C);
  static const Color colorSecondaryGreen = Color(0xFF4CAF50);

  static Color get colorBackground =>
      isDark ? const Color(0xFF121212) : const Color(0xfff3f2f7);

  static Color get colorFontPrimary =>
      isDark ? const Color(0xFFF5F5F5) : const Color(0xFF000000);
  static Color get colorFontSecondary =>
      isDark ? const Color(0xFFD0D0D0) : const Color(0xFF292828);

  static Color get colorDivider =>
      isDark ? const Color(0xFF2A2A2C) : const Color(0xFFE9E9E9);

  static const Color colorSuccess50 = Color(0xFFF1FCF3);
  static const Color colorSuccess500 = Color(0xFF34C759);

  static Color get colorDoveGray50 =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F7F7);
  static Color get colorDoveGray100 =>
      isDark ? const Color(0xFF2C2C2E) : const Color(0xFFDCDADA);
  static Color get colorDoveGray300 =>
      isDark ? const Color(0xFF48484A) : const Color(0xFFBEBBBB);
  static Color get colorDoveGray600 =>
      isDark ? const Color(0xFFA0A0A0) : const Color(0xFF726E6E);
  static Color get colorDoveGray800 =>
      isDark ? const Color(0xFFC7C7C7) : const Color(0xFF474545);
  static Color get colorDoveGray900 =>
      isDark ? const Color(0xFFD6D6D6) : const Color(0xFF3E3C3C);
  static Color get colorDoveGray950 =>
      isDark ? const Color(0xFFEDEDED) : const Color(0xFF292828);

  static const Color colorError500 = Color(0xFFFF3B30);
  static const Color colorRed = Color(0xFF9B1724);
  static const Color colorToast = Color(0xFFFFFFFF);

  static Color get colorTextField =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA);

  static Color get colorPlaceHolder =>
      isDark ? const Color(0xFF6E6E70) : const Color(0xFFC4C5C4);

  static Color get colorCard =>
      isDark ? const Color(0xFF232325) : const Color(0xFFE7E7E7);

  static const Color colorSplash = Color(0x000ffbbb);

  static Color get colorTextFieldFill =>
      isDark ? const Color(0xFF1E1E20) : const Color(0xFFF7F8F9);
  static Color colorTextFieldFillError = const Color(
    0xFFBF4034,
  ).withValues(alpha: 0.08);
  static Color get colorTextFieldEnabledBorder => colorPlaceHolder;
  static Color get colorTextFieldFocusedBorder => colorPlaceHolder;
  static Color colorTextFieldErrorBorder = const Color(0xFFBF4034);

  static Color colorSelectedItem = const Color(
    0xFFBF4034,
  ).withValues(alpha: 0.05);

  static Color get colorGrey0 =>
      isDark ? const Color(0xFF2A2A2C) : const Color(0xFFF7F8F9);
  static Color get colorGrey1 =>
      isDark ? const Color(0xFF3A3A3C) : const Color(0xFFEFEFEF);
  static Color get colorGrey2 =>
      isDark ? const Color(0xFF9E9E9E) : const Color(0xff797979);
  static Color get colorGrey3 =>
      isDark ? const Color(0xFFC7C7C7) : const Color(0xFF474545);
  static Color get colorGrey4 =>
      isDark ? const Color(0xFFA9AFB8) : const Color(0xFF777F8B);
  static Color get colorGrey5 =>
      isDark ? const Color(0xFFB8BEC7) : const Color(0xFF555D68);
  static Color get colorGrey6 =>
      isDark ? const Color(0xFFA8A4A4) : const Color(0xFF726E6E);
  static Color get colorGrey7 =>
      isDark ? const Color(0xFF9099A6) : const Color(0xFFA5AEBB);
  static Color get colorNeutralGrey =>
      isDark ? const Color(0xFFAEB4BD) : const Color(0xFF78808B);
  static const Color colorError = Color(0xffe61f34);
  static const Color colorRed100 = Color(0xffBF4034);
  static const Color colorError200 = Color(0xff9B1724);
  static const Color colorError300 = Color(0xffFF3B30);
  static Color get colorWhite =>
      isDark ? const Color(0xFF1E1E20) : const Color(0xffFFFFFF);
  static Color get colorBlack =>
      isDark ? const Color(0xFFF2F2F2) : const Color(0xff0C0C0C);
  static const Color colorGreen = Color(0x1434C759);
  static const Color colorGreen2 = Color(0xFF191D23);
  static const Color colorGreen3 = Color(0xFF34C759);
  static const Color colorSpin = Color(0xFFFFFFFF);
  static const Color colorOrange = Color(0xFFFF9500);
  static const Color colorBlue = Color(0xFF007AFF);
  static const Color colorYellow = Color(0xFFFFCC00);
  static const Color colorMojo = Color(0xFFFDF4F3);

  static Color get shimmerBaseColor =>
      isDark ? shimmerBaseColorDark : Colors.grey.shade300;
  static Color get shimmerHighlightColor =>
      isDark ? shimmerHighlightColorDark : Colors.grey.shade100;
  static Color shimmerBaseColorDark = Colors.grey.shade700;
  static Color shimmerHighlightColorDark = Colors.grey.shade800;
}
