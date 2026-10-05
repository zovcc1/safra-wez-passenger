import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/push_notification_service.dart';

enum MainTab { trips, bookings, paymentRequests, visas, profile }

class MainPageController extends GetxController {
  final List<MainTab> tabs = const [
    MainTab.trips,
    MainTab.bookings,
    MainTab.paymentRequests,
    MainTab.visas,
    MainTab.profile,
  ];

  final PageController pageController = PageController();
  final pageIndex = 0.obs;

  @override
  void onReady() {
    super.onReady();
    // إشعار FCM فتح التطبيق: نوجّهه الآن بعد أن أصبحت الشاشة الرئيسية جاهزة.
    Get.find<PushNotificationService>().consumePendingTap();
  }

  void changePage(MainTab tab) {
    final index = tabs.indexOf(tab);
    if (index == -1 || pageIndex.value == index) return;
    pageIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
