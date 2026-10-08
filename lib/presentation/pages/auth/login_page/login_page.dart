import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/labeled_text_field.dart';
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
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSize.sWidth * 0.07),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppSize.sHeight * 0.06),
                    const _LogoBadge(),
                    const SizedBox(height: AppPadding.p8),
                    Text(
                      "auth_login_welcome_title".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                    const SizedBox(height: AppPadding.p4),
                    Text(
                      "auth_login_welcome_subtitle".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s12,
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
                    const SizedBox(height: AppPadding.p12),
                    Obx(
                      () => LabeledTextField(
                        label: "auth_password_label".tr,
                        hint: "••••••••",
                        obscureText: controller.obscurePassword.value,
                        controller: controller.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: controller.validatePassword,
                        icon: Assets.icons.passwordIcon.svg(
                          width: 22,
                          colorFilter: ColorFilter.mode(
                            ColorManager.colorPrimary,
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
                              size: 22,
                              color: ColorManager.colorGrey6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: controller.goToForgotPassword,
                        child: Text(
                          "auth_forgot_password".tr,
                          style: TextStyle(
                            fontSize: FontSize.s12,
                            color: ColorManager.colorGrey6,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => AppButton(
                        text: "auth_login_submit_button".tr,
                        radius: 12,
                        minHeight: 44,
                        loadingMode:
                            controller.loadingState.value ==
                            LoadingState.loading,
                        onPressed: controller.login,
                      ),
                    ),
                    const SizedBox(height: AppPadding.p12),
                    Center(
                      child: TextButton(
                        onPressed: controller.goToRegister,
                        child: Text.rich(
                          TextSpan(
                            text: "auth_no_account_prefix".tr,
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.colorGrey6,
                            ),
                            children: [
                              TextSpan(
                                text: "auth_create_account_button".tr,
                                style: TextStyle(
                                  fontSize: FontSize.s12,
                                  color: ColorManager.colorPrimary,
                                  fontWeight: FontWeight.w500,
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
                          style: TextStyle(
                            fontSize: FontSize.s12,
                            color: ColorManager.colorGrey6,
                          ),
                        ),
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

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 110,
        height: 110,
        child: Image.asset("assets/logo/LOGO_SAFRA.png", fit: BoxFit.contain),
      ),
    );
  }
}
