import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/forgot_password_page/forgot_password_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/widgets/phone_number_widget.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordPageController> {
  const ForgotPasswordPage({super.key});

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
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSize.sHeight * 0.04),
                  Text(
                    "forgot_password_title".tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headlineLarge,
                  ),
                  SizedBox(height: AppSize.s8),
                  Text(
                    "forgot_password_subtitle".tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: ColorManager.colorDoveGray600,
                    ),
                  ),
                  SizedBox(height: AppSize.sHeight * 0.06),
                  PhoneNumberInput(
                    title: "auth_phone_label".tr,
                    hintText: "912345678",
                    textEditingController: controller.phoneController,
                    countryCode: controller.countryCode,
                    readOnly: false,
                    languageCode: AppTranslations.currentLang,
                    validator: controller.phoneValidator,
                    onChanged: controller.onPhoneChanged,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: AppSize.s8),
                  Obx(
                    () => AppButton(
                      text: "common_send".tr,
                      radius: 14,
                      minHeight: 54,
                      loadingMode:
                          controller.loadingState.value == LoadingState.loading,
                      onPressed: controller.submit,
                    ),
                  ),
                  SizedBox(height: AppSize.s24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
