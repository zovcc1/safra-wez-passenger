import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/labeled_text_field.dart';
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
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: ColorManager.colorFontPrimary),
        ),
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSize.sWidth * 0.07),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppSize.sHeight * 0.03),
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ColorManager.colorPrimary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 28,
                          color: ColorManager.colorPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.p16),
                    Text(
                      "forgot_password_title".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                    const SizedBox(height: AppPadding.p4),
                    Text(
                      "forgot_password_subtitle".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        height: 1.5,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                    SizedBox(height: AppSize.sHeight * 0.04),
                    FieldLabel("auth_phone_label".tr),
                    PhoneNumberInput(
                      title: "",
                      hintText: "912345678",
                      minHeight: 42,
                      borderRadius: 10,
                      fieldStyle: true,
                      textEditingController: controller.phoneController,
                      countryCode: controller.countryCode,
                      readOnly: false,
                      languageCode: AppTranslations.currentLang,
                      validator: controller.phoneValidator,
                      onChanged: controller.onPhoneChanged,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: AppPadding.p16),
                    Obx(
                      () => AppButton(
                        text: "common_send".tr,
                        radius: 12,
                        minHeight: 44,
                        loadingMode:
                            controller.loadingState.value ==
                            LoadingState.loading,
                        onPressed: controller.submit,
                      ),
                    ),
                    const SizedBox(height: AppPadding.p24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
