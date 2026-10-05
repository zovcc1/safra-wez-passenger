import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/register_page/register_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/widgets/phone_number_widget.dart';

class RegisterPage extends GetView<RegisterPageController> {
  const RegisterPage({super.key});

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
                  Text(
                    "auth_create_account_button".tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headlineLarge,
                  ),
                  SizedBox(height: AppSize.s8),
                  Text(
                    "auth_register_subtitle".tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: ColorManager.colorDoveGray600,
                    ),
                  ),
                  SizedBox(height: AppSize.sHeight * 0.04),
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
                  CustomTextField(
                    title: "auth_national_id_label".tr,
                    hint: "1234509999",
                    textEditingController: controller.nationalIdController,
                    textInputType: TextInputType.number,
                    fillColor: ColorManager.colorWhite,
                    borderRadius: 10,
                    icon: Icon(
                      Icons.badge_outlined,
                      size: AppSize.s20,
                      color: ColorManager.colorDoveGray600,
                    ),
                    validator: controller.validateNationalId,
                  ),
                  CustomTextField(
                    title: "auth_full_name_label".tr,
                    hint: "auth_full_name_hint".tr,
                    textEditingController: controller.fullNameController,
                    textInputType: TextInputType.name,
                    fillColor: ColorManager.colorWhite,
                    borderRadius: 10,
                    icon: Assets.icons.userIcon.svg(
                      width: AppSize.s20,
                      colorFilter: ColorFilter.mode(
                        ColorManager.colorDoveGray600,
                        BlendMode.srcIn,
                      ),
                    ),
                    validator: controller.validateFullName,
                  ),
                  Obx(
                    () => CustomTextField(
                      title: "auth_password_label".tr,
                      hint: "••••••••",
                      obscureText: controller.obscurePassword.value,
                      textEditingController: controller.passwordController,
                      textInputType: TextInputType.visiblePassword,
                      fillColor: ColorManager.colorWhite,
                      borderRadius: 10,
                      validator: controller.validatePassword,
                      icon: Assets.icons.passwordIcon.svg(
                        width: AppSize.s20,
                        colorFilter: ColorFilter.mode(
                          ColorManager.colorDoveGray600,
                          BlendMode.srcIn,
                        ),
                      ),
                      suffixIcon: InkWell(
                        onTap: controller.togglePasswordVisibility,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: AppSize.s20,
                            color: ColorManager.colorDoveGray600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => CustomTextField(
                      title: "auth_confirm_password_label".tr,
                      hint: "••••••••",
                      obscureText: controller.obscureConfirmPassword.value,
                      textEditingController:
                          controller.confirmPasswordController,
                      textInputType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      fillColor: ColorManager.colorWhite,
                      borderRadius: 10,
                      validator: controller.validateConfirmPassword,
                      icon: Assets.icons.passwordIcon.svg(
                        width: AppSize.s20,
                        colorFilter: ColorFilter.mode(
                          ColorManager.colorDoveGray600,
                          BlendMode.srcIn,
                        ),
                      ),
                      suffixIcon: InkWell(
                        onTap: controller.toggleConfirmPasswordVisibility,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            controller.obscureConfirmPassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: AppSize.s20,
                            color: ColorManager.colorDoveGray600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSize.s8),
                  Obx(
                    () => AppButton(
                      text: "auth_create_account_button".tr,
                      radius: 14,
                      minHeight: 54,
                      loadingMode:
                          controller.loadingState.value == LoadingState.loading,
                      onPressed: controller.register,
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
