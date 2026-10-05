import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/pin_put_custom.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/verify_otp_page/verify_otp_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class VerifyOtpPage extends GetView<VerifyOtpPageController> {
  const VerifyOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: ColorManager.colorBackground,
        appBar: AppBar(
          backgroundColor: ColorManager.colorBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: ColorManager.colorFontPrimary),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSize.sWidth * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSize.sHeight * 0.04),
                Text(
                  "verify_otp_title".tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.headlineLarge,
                ),
                SizedBox(height: AppSize.s8),
                Text(
                  "verify_otp_subtitle".trParams({
                    "phone": controller.phoneNumber,
                  }),
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: ColorManager.colorDoveGray600,
                  ),
                ),
                SizedBox(height: AppSize.sHeight * 0.06),
                Obx(
                  () => Column(
                    children: [
                      IgnorePointer(
                        ignoring:
                            controller.loadingState.value ==
                                LoadingState.loading ||
                            controller.remainingAttempts.value <= 0,
                        child: PinPutCustom(
                          controller: controller.codeController,
                          onCompleted: controller.verify,
                        ),
                      ),
                      if (controller.remainingAttempts.value <= 0)
                        Padding(
                          padding: const EdgeInsets.only(top: AppPadding.p16),
                          child: Text(
                            "verify_otp_attempts_exhausted".tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ColorManager.colorError500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: AppSize.sHeight * 0.04),
                Center(
                  child: Obx(
                    () => controller.resendCooldown.value > 0
                        ? Text(
                            "verify_otp_resend_cooldown".trParams({
                              "seconds": "${controller.resendCooldown.value}",
                            }),
                            style: Get.textTheme.bodyMedium?.copyWith(
                              color: ColorManager.colorDoveGray600,
                            ),
                          )
                        : TextButton(
                            onPressed: controller.resending.value
                                ? null
                                : controller.resend,
                            child: Text(
                              "verify_otp_resend_button".tr,
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: ColorManager.colorPrimary,
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: AppSize.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
