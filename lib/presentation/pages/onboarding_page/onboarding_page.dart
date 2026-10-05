import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/pages/onboarding_page/onboarding_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class OnboardingPage extends GetView<OnboardingPageController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorWhite,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.p16),
                child: Obx(
                  () => controller.isLastPage
                      ? const SizedBox(height: 24)
                      : TextButton(
                          onPressed: controller.skip,
                          child: Text(
                            "onboarding_skip".tr,
                            style: TextStyle(color: ColorManager.colorGrey6),
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.slides.length,
                itemBuilder: (context, index) {
                  final slide = controller.slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          slide.illustration,
                          height: AppSize.s140 * 2,
                        ),
                        const SizedBox(height: AppPadding.p28),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSize.s20,
                            fontWeight: FontWeight.bold,
                            color: ColorManager.colorFontPrimary,
                          ),
                        ),
                        const SizedBox(height: AppPadding.p12),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSize.s14,
                            color: ColorManager.colorDoveGray600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: controller.currentIndex.value == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.currentIndex.value == index
                          ? ColorManager.colorPrimary
                          : ColorManager.colorDoveGray300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppPadding.p24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
              child: Obx(
                () => controller.isLastPage
                    ? Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: "auth_login_button".tr,
                              backgroundColor: ColorManager.colorWhite,
                              fontColor: ColorManager.colorPrimary,
                              border: Border.all(
                                color: ColorManager.colorPrimary,
                              ),
                              onPressed: controller.goToLogin,
                            ),
                          ),
                          const SizedBox(width: AppPadding.p12),
                          Expanded(
                            child: AppButton(
                              text: "auth_create_account_button".tr,
                              onPressed: controller.goToRegister,
                            ),
                          ),
                        ],
                      )
                    : AppButton(
                        text: "onboarding_next".tr,
                        onPressed: controller.next,
                      ),
              ),
            ),
            Obx(
              () => controller.isLastPage
                  ? TextButton(
                      onPressed: controller.continueAsGuest,
                      child: Text("guest_continue_button".tr),
                    )
                  : const SizedBox(height: AppPadding.p24),
            ),
            const SizedBox(height: AppPadding.p8),
          ],
        ),
      ),
    );
  }
}
