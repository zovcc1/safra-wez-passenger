import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

List<OnboardingSlide> _buildOnboardingSlides() => [
  OnboardingSlide(
    title: "onboarding_slide1_title".tr,
    description: "onboarding_slide1_description".tr,
    illustration: "assets/illustrations/onboarding_1_search_trip.svg",
  ),
  OnboardingSlide(
    title: "onboarding_slide2_title".tr,
    description: "onboarding_slide2_description".tr,
    illustration: "assets/illustrations/onboarding_2_book_easily.svg",
  ),
  OnboardingSlide(
    title: "onboarding_slide3_title".tr,
    description: "onboarding_slide3_description".tr,
    illustration: "assets/illustrations/onboarding_3_stay_informed.svg",
  ),
];

class OnboardingSlide {
  final String title;
  final String description;
  final String illustration;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

class OnboardingPageController extends GetxController {
  final CacheService cacheService = Get.find<CacheService>();

  final pageController = PageController();
  final currentIndex = 0.obs;

  final List<OnboardingSlide> slides = _buildOnboardingSlides();

  bool get isLastPage => currentIndex.value == slides.length - 1;

  void onPageChanged(int index) => currentIndex.value = index;

  void next() {
    if (isLastPage) return;
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    await cacheService.setOnboardingSeen();
  }

  Future<void> skip() async {
    await _finish();
    Get.offAllNamed(AppRoutes.loginRoute);
  }

  Future<void> continueAsGuest() async {
    await _finish();
    await cacheService.setGuestMode(true);
    Get.offAllNamed(AppRoutes.mainRoute);
  }

  Future<void> goToLogin() async {
    await _finish();
    Get.offAllNamed(AppRoutes.loginRoute);
  }

  Future<void> goToRegister() async {
    await _finish();
    Get.offAllNamed(AppRoutes.registerRoute);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
