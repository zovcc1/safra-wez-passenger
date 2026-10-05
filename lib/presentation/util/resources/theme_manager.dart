import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

import 'values_manager.dart';

abstract class MainThemeApp {
  late ThemeData themeData;
}

class LightModeTheme implements MainThemeApp {
  @override
  ThemeData themeData = _buildThemeData(isDark: false);
}

class DarkModeTheme implements MainThemeApp {
  @override
  ThemeData themeData = _buildThemeData(isDark: true);
}

/// يبني [ThemeData] لمود محدد. يضبط [ColorManager.isDark] مؤقتًا أثناء البناء
/// بحيث تُرجع كل ثوابت [ColorManager] القيمة الصحيحة لهذا المود تحديدًا،
/// بغض النظر عن المود الفعلي الحالي للتطبيق.
ThemeData _buildThemeData({required bool isDark}) {
  ColorManager.isDark = isDark;
  final brightness = isDark ? Brightness.dark : Brightness.light;
  return ThemeData(
    brightness: brightness,
    dividerColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorManager.colorPrimary,
      brightness: brightness,
    ),
    primaryColor: ColorManager.colorPrimary,
    cardColor: ColorManager.colorCard,
    scaffoldBackgroundColor: ColorManager.colorBackground,
    disabledColor: ColorManager.colorGrey1,
    splashColor: ColorManager.colorSplash,
    popupMenuTheme: PopupMenuThemeData(
      surfaceTintColor: ColorManager.colorBackground,
      shadowColor: Colors.black,
      color: ColorManager.colorWhite,
    ),
    iconTheme: IconThemeData(color: ColorManager.colorDoveGray800),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.grey,
        backgroundColor: ColorManager.colorGrey0,
        shadowColor: Colors.transparent,
      ),
    ),
    // Text color
    primaryColorLight: ColorManager.colorFontPrimary,
    primaryColorDark: ColorManager.colorFontSecondary,
    hintColor: ColorManager.colorPlaceHolder,
    fontFamily: AppTranslations.appFontFamily,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: ColorManager.colorFontPrimary,
        fontWeight: FontWeight.w800,
        fontSize: FontSize.s22,
      ),
      headlineMedium: TextStyle(
        color: ColorManager.colorFontPrimary,
        fontWeight: FontWeight.w800,
        fontSize: FontSize.s18,
      ),
      headlineSmall: TextStyle(
        color: ColorManager.colorDoveGray600,
        fontSize: FontSize.s16,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: TextStyle(
        color: ColorManager.colorFontPrimary,
        fontWeight: FontWeight.bold,
        fontSize: FontSize.s16,
      ),
      displaySmall: TextStyle(
        color: ColorManager.colorDoveGray950,
        fontWeight: FontWeight.w600,
        fontSize: FontSize.s14,
      ),
      bodyLarge: TextStyle(
        color: ColorManager.colorDoveGray950,
        fontWeight: FontWeight.bold,
        fontSize: FontSize.s14,
      ),
      bodyMedium: TextStyle(
        color: ColorManager.colorDoveGray900,
        fontWeight: FontWeight.w600,
        fontSize: FontSize.s13,
      ),
      bodySmall: TextStyle(
        color: ColorManager.colorDoveGray600,
        fontWeight: FontWeight.normal,
        fontSize: FontSize.s12,
      ),

      /// 1. title large
      titleLarge: TextStyle(
        color: ColorManager.colorFontPrimary,
        fontWeight: FontWeight.bold,
        fontSize: FontSize.s15,
      ),
      titleMedium: TextStyle(
        color: ColorManager.colorFontPrimary,
        fontWeight: FontWeight.bold,
        fontSize: FontSize.s13,
      ),
      //I use this in small title in home page
      titleSmall: TextStyle(
        color: ColorManager.colorDoveGray600,
        fontWeight: FontWeight.bold,
        fontSize: FontSize.s14,
      ),
      // use this in label of icons in popupmenu
      labelLarge: TextStyle(
        color: ColorManager.colorDoveGray950,
        fontWeight: FontWeight.w600,
        fontSize: FontSize.s16,
      ),
      labelMedium: TextStyle(
        color: ColorManager.colorDoveGray600,
        fontWeight: FontWeight.w500,
        fontSize: FontSize.s12,
      ),
      labelSmall: TextStyle(
        color: ColorManager.colorDoveGray800,
        fontSize: FontSize.s11,
        fontWeight: FontWeight.normal,
      ),
    ),
    dividerTheme: DividerThemeData(color: ColorManager.colorDivider),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorManager.colorWhite,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: ColorManager.colorSecondary,
      unselectedItemColor: ColorManager.colorBlack,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: FontSize.s12,
        color: ColorManager.colorSecondary,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: FontSize.s12,
        color: ColorManager.colorBlack,
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: ColorManager.colorWhite,
      elevation: 0,
      iconTheme: IconThemeData(
        color: ColorManager.colorDoveGray800,
        size: AppSize.s20,
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: FontSize.s18,
        color: ColorManager.colorFontPrimary,
        fontFamily: AppTranslations.appFontFamily,
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: ColorManager.colorWhite),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: ColorManager.colorWhite,
      elevation: 1,
      weekdayStyle: TextStyle(
        color: ColorManager.colorGrey3,
        fontWeight: FontWeight.bold,
        fontSize: FontSize.s16,
      ),
      dayStyle: TextStyle(
        color: ColorManager.colorFontPrimary,
        fontWeight: FontWeight.w600,
        fontSize: FontSize.s14,
      ),
    ),
    // input decoration theme (text form field)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorManager.colorWhite,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppPadding.p16,
        vertical: AppPadding.p20,
      ),
      // hint style
      hintStyle: TextStyle(
        color: ColorManager.colorGrey7,
        fontWeight: FontWeight.w500,
        fontSize: FontSize.s12,
        fontFamily: AppTranslations.appFontFamily,
      ),
      labelStyle: TextStyle(
        color: ColorManager.colorFontPrimary,
        fontWeight: FontWeight.w500,
        fontFamily: AppTranslations.appFontFamily,
      ),
      errorStyle: TextStyle(
        color: ColorManager.colorError,
        fontWeight: FontWeight.w500,
        fontFamily: AppTranslations.appFontFamily,
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.colorTextFieldFocusedBorder,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSize.s10)),
      ),
      // enabled border style
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.colorTextFieldEnabledBorder,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSize.s10)),
      ),
      // focused border style
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.colorTextFieldFocusedBorder,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSize.s10)),
      ),
      // error border style
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.colorTextFieldErrorBorder,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSize.s10)),
      ),
      // focused border style
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.colorTextFieldErrorBorder,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSize.s10)),
      ),
    ),
  );
}
