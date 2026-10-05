import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/data/dto/push_token_dto.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/firebase_options.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/notification_router.dart';

/// FCM: كل إشعار يحمل في data: type, notification_id, app_context + مفاتيح
/// النوع (booking_id, trip_id, ...). التوجيه عبر [NotificationRouter].
/// معالج الخلفية/الإغلاق الكامل: لازم يكون top-level. الإشعار الذي يحمل كتلة
/// `notification` يعرضه النظام نفسه؛ وهنا لا نعرض شيئًا لأن حمولة data وحدها
/// (type, notification_id, app_context + المفاتيح) لا تحمل عنوانًا ولا نصًا.
/// التوجيه عند الضغط يتم عبر getInitialMessage / onMessageOpenedApp.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// رسالة ضُغط عليها قبل أن يصبح التطبيق جاهزًا للتوجيه (cold start / قبل
  /// تسجيل الدخول). تُستهلك من [consumePendingTap] بعد دخول الشاشة الرئيسية.
  Map<String, dynamic>? _pendingTap;
  bool _listening = false;

  Future<String?> getDeviceToken() async {
    try {
      await _fcm.requestPermission();
      return await _fcm.getToken();
    } catch (e) {
      debugPrint("FCM token unavailable: $e");
      return null;
    }
  }

  String get platformName {
    if (Platform.isAndroid) return "android";
    if (Platform.isIOS) return "ios";
    return "web";
  }

  /// يُستدعى مرة من main(): يستمع للرسائل ويلتقط الإشعار الذي فتح التطبيق.
  Future<void> init() async {
    if (_listening) return;
    _listening = true;
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final initial = await _fcm.getInitialMessage();
      if (initial != null) _pendingTap = Map.of(initial.data);

      FirebaseMessaging.onMessageOpenedApp.listen((m) {
        _pendingTap = Map.of(m.data);
        consumePendingTap();
      });
      FirebaseMessaging.onMessage.listen((m) {
        final text = m.notification?.body;
        if (text == null || text.isEmpty) return;
        CustomToasts(message: text, type: CustomToastType.success).show();
      });
      _fcm.onTokenRefresh.listen(_registerRefreshedToken);
    } catch (e) {
      debugPrint("FCM init failed: $e");
    }
  }

  Future<void> _registerRefreshedToken(String token) async {
    final cache = Get.find<CacheService>();
    if (!cache.isLoggedIn()) return;
    final response = await Get.find<AuthRepo>().registerPushToken(
      PushTokenDto(token: token, platform: platformName),
    );
    if (response.success) await cache.storeLastPushToken(token);
  }

  /// يوجّه الإشعار المعلّق إن وُجد وكان المستخدم داخل التطبيق.
  void consumePendingTap() {
    final data = _pendingTap;
    if (data == null) return;
    if (!Get.find<CacheService>().isLoggedIn()) return;
    _pendingTap = null;
    NotificationRouter.open(data["type"]?.toString() ?? "", data);
  }
}
