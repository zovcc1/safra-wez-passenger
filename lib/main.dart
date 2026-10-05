import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:safraa_passenger_app/core/services/push_notification_service.dart';
import 'package:safraa_passenger_app/core/app/app.dart';
import 'package:safraa_passenger_app/core/app_config/app_binding.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  AppBinding().dependencies();
  setupTimeagoLocales();
  await Get.find<PushNotificationService>().init();
  await AppTranslations.init();
  runApp(
    DevicePreview(
      builder: (context) => MyApp(),
      enabled: false, // enable if u want to test devices
    ),
  );
}

void setupTimeagoLocales() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('ar', timeago.ArMessages());
}
