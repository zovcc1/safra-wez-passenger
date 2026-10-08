import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/pages/onboarding_page/onboarding_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class OnboardingPage extends GetView<OnboardingPageController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p16,
                    vertical: AppPadding.p8,
                  ),
                  child: Obx(
                    () => controller.isLastPage
                        ? const SizedBox(height: 40)
                        : TextButton(
                            onPressed: controller.skip,
                            child: Text(
                              "onboarding_skip".tr,
                              style: TextStyle(
                                fontSize: FontSize.s13,
                                color: ColorManager.colorGrey6,
                              ),
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
                  itemBuilder: (context, index) => _Slide(
                    slide: controller.slides[index],
                    index: index,
                    pageController: controller.pageController,
                  ),
                ),
              ),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: controller.currentIndex.value == index ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: controller.currentIndex.value == index
                            ? ColorManager.colorPrimary
                            : ColorManager.colorTextFieldEnabledBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.p20),
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
                                radius: 12,
                                minHeight: 44,
                                onPressed: controller.goToLogin,
                              ),
                            ),
                            const SizedBox(width: AppPadding.p12),
                            Expanded(
                              child: AppButton(
                                text: "auth_create_account_button".tr,
                                radius: 12,
                                minHeight: 44,
                                onPressed: controller.goToRegister,
                              ),
                            ),
                          ],
                        )
                      : AppButton(
                          text: "onboarding_next".tr,
                          radius: 12,
                          minHeight: 44,
                          onPressed: controller.next,
                        ),
                ),
              ),
              Obx(
                () => controller.isLastPage
                    ? TextButton(
                        onPressed: controller.continueAsGuest,
                        child: Text(
                          "guest_continue_button".tr,
                          style: TextStyle(
                            fontSize: FontSize.s13,
                            color: ColorManager.colorGrey6,
                          ),
                        ),
                      )
                    : const SizedBox(height: AppPadding.p24),
              ),
              const SizedBox(height: AppPadding.p8),
            ],
          ),
        ),
      ),
    );
  }
}

/// شريحة واحدة: الرسمة داخل هالة ملوّنة خفيفة، مع حركة مرافقة للسحب
/// (تكبير وتلاشي للرسمة، وانزلاق خفيف للنص).
class _Slide extends StatelessWidget {
  const _Slide({
    required this.slide,
    required this.index,
    required this.pageController,
  });

  final OnboardingSlide slide;
  final int index;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final page =
            pageController.hasClients && pageController.position.haveDimensions
            ? (pageController.page ?? index.toDouble())
            : index.toDouble();
        final delta = (page - index).clamp(-1.0, 1.0);
        final focus = 1 - delta.abs();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: (0.35 + 0.65 * focus).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + 0.15 * focus,
                  child: Container(
                    padding: const EdgeInsets.all(AppPadding.p24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorManager.colorPrimary.withValues(alpha: 0.07),
                    ),
                    child: SvgPicture.asset(
                      slide.illustration,
                      height: AppSize.s140 * 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.p24),
              Transform.translate(
                offset: Offset(delta * 40, 0),
                child: Opacity(
                  opacity: focus.clamp(0.0, 1.0),
                  child: Column(
                    children: [
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSize.s18,
                          fontWeight: FontWeight.w500,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                      const SizedBox(height: AppPadding.p8),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSize.s13,
                          height: 1.6,
                          color: ColorManager.colorGrey6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
