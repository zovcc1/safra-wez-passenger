import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/labeled_text_field.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/register_page/register_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/widgets/phone_number_widget.dart';

class RegisterPage extends GetView<RegisterPageController> {
  const RegisterPage({super.key});

  Widget _fieldIcon(Widget Function(Color color) build) =>
      build(ColorManager.colorPrimary);

  Widget _eye(bool obscured, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 22,
        color: ColorManager.colorGrey6,
      ),
    ),
  );

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
                    Text(
                      "auth_create_account_button".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                    const SizedBox(height: AppPadding.p4),
                    Text(
                      "auth_register_subtitle".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                    SizedBox(height: AppSize.sHeight * 0.03),
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
                    const SizedBox(height: AppPadding.p12),
                    LabeledTextField(
                      label: "auth_national_id_label".tr,
                      hint: "1234509999",
                      controller: controller.nationalIdController,
                      keyboardType: TextInputType.number,
                      icon: Icon(
                        Icons.badge_outlined,
                        size: 22,
                        color: ColorManager.colorPrimary,
                      ),
                      validator: controller.validateNationalId,
                    ),
                    LabeledTextField(
                      label: "auth_full_name_label".tr,
                      hint: "auth_full_name_hint".tr,
                      controller: controller.fullNameController,
                      keyboardType: TextInputType.name,
                      icon: _fieldIcon(
                        (c) => Assets.icons.userIcon.svg(
                          width: 22,
                          colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
                        ),
                      ),
                      validator: controller.validateFullName,
                    ),
                    Obx(
                      () => LabeledTextField(
                        label: "auth_password_label".tr,
                        hint: "••••••••",
                        obscureText: controller.obscurePassword.value,
                        controller: controller.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        validator: controller.validatePassword,
                        icon: _fieldIcon(
                          (c) => Assets.icons.passwordIcon.svg(
                            width: 22,
                            colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
                          ),
                        ),
                        suffixIcon: _eye(
                          controller.obscurePassword.value,
                          controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    Obx(
                      () => LabeledTextField(
                        label: "auth_confirm_password_label".tr,
                        hint: "••••••••",
                        obscureText: controller.obscureConfirmPassword.value,
                        controller: controller.confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: controller.validateConfirmPassword,
                        icon: _fieldIcon(
                          (c) => Assets.icons.passwordIcon.svg(
                            width: 22,
                            colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
                          ),
                        ),
                        suffixIcon: _eye(
                          controller.obscureConfirmPassword.value,
                          controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.p4),
                    Obx(
                      () => AppButton(
                        text: "auth_create_account_button".tr,
                        radius: 12,
                        minHeight: 44,
                        loadingMode:
                            controller.loadingState.value ==
                            LoadingState.loading,
                        onPressed: controller.register,
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
