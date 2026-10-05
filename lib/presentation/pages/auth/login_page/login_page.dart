import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/login_page/login_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/widgets/phone_number_widget.dart';

class LoginPage extends GetView<LoginPageController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: ColorManager.colorBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSize.sWidth * 0.07),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSize.sHeight * 0.08),
                  const _LogoBadge(),
                  Text(
                    "auth_login_welcome_title".tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headlineLarge,
                  ),
                  SizedBox(height: AppSize.s8),
                  Text(
                    "auth_login_welcome_subtitle".tr,
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
                  Obx(
                    () => CustomTextField(
                      title: "auth_password_label".tr,
                      hint: "••••••••",
                      obscureText: controller.obscurePassword.value,
                      textEditingController: controller.passwordController,
                      textInputType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
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
                  SizedBox(height: AppSize.s8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: controller.goToForgotPassword,
                      child: Text(
                        "auth_forgot_password".tr,
                        style: Get.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Obx(
                    () => AppButton(
                      text: "auth_login_submit_button".tr,
                      radius: 14,
                      minHeight: 54,
                      loadingMode:
                          controller.loadingState.value == LoadingState.loading,
                      onPressed: controller.login,
                    ),
                  ),
                  SizedBox(height: AppSize.s16),
                  Center(
                    child: TextButton(
                      onPressed: controller.goToRegister,
                      child: Text.rich(
                        TextSpan(
                          text: "auth_no_account_prefix".tr,
                          style: Get.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: "auth_create_account_button".tr,
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: ColorManager.colorPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: controller.continueAsGuest,
                      child: Text(
                        "guest_continue_button".tr,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: ColorManager.colorDoveGray600,
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
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 130,
        height: 130,
        child: Image.asset("assets/logo/LOGO_SAFRA.png", fit: BoxFit.contain),
      ),
    );
  }
}
