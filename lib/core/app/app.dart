import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/theme_manager.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/core/services/theme_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cacheService = Get.find<CacheService>();
    final themeController = Get.find<ThemeController>();
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final lightTheme = LightModeTheme().themeData;
      final darkTheme = DarkModeTheme().themeData;
      // إعادة ضبط المود الفعلي بعد بناء الثيمين، لأن بناء كل ثيم يُغيّر
      // ColorManager.isDark مؤقتًا (راجع theme_manager.dart).
      ColorManager.isDark = isDark;
      return GetMaterialApp(
        title: "Safraa Passenger",
        navigatorKey: appNavigatorKey,
        translations: AppTranslations(),
        locale: Locale(cacheService.getLanguage()),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        getPages: NavigationManager.getPages,
        initialRoute: AppRoutes.splashRoute,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 320),
        fallbackLocale: const Locale('ar'),
        supportedLocales: AppTranslations.supportedLocales,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
