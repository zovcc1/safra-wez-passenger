import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/presentation/util/resources/fonts.gen.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class AppTranslations extends Translations {
  static late Map<String, Map<String, String>> _keysMap;

  @override
  Map<String, Map<String, String>> get keys => _keysMap;

  static Future init() async {
    final en = await rootBundle.loadString('lang/en.json');
    final ar = await rootBundle.loadString('lang/ar.json');

    _keysMap = {
      'en': Map<String, String>.from(json.decode(en)),
      'ar': Map<String, String>.from(json.decode(ar)),
    };
  }

  static List<Locale> get supportedLocales => const [
    Locale('ar'),
    Locale('en'),
  ];

  static void changeLocale(String languageCode) async {
    final cacheService = Get.find<CacheService>();
    if (cacheService.getLanguage() == languageCode) return;
    await cacheService.saveLanguage(languageCode);
    await Get.updateLocale(Locale(languageCode));
    Get.offAllNamed(AppRoutes.mainRoute);
  }

  static bool get isArabic => currentLang == 'ar';

  static String get currentLang => Get.find<CacheService>().getLanguage();

  static String get appFontFamily => FontFamily.thmanyahSans;
}
