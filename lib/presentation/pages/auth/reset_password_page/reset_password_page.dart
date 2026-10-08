import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/labeled_text_field.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/reset_password_page/reset_password_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class ResetPasswordPage extends GetView<ResetPasswordPageController> {
  const ResetPasswordPage({super.key});

  Widget _passwordIcon() => Assets.icons.passwordIcon.svg(
    width: 22,
    colorFilter: ColorFilter.mode(ColorManager.colorPrimary, BlendMode.srcIn),
  );

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
                          Icons.password_rounded,
                          size: 28,
                          color: ColorManager.colorPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.p16),
                    Text(
                      "reset_password_title".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                    const SizedBox(height: AppPadding.p4),
                    Text(
                      "reset_password_subtitle".trParams({
                        "phone": controller.phoneNumber,
                      }),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        height: 1.5,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                    SizedBox(height: AppSize.sHeight * 0.04),
                    LabeledTextField(
                      label: "reset_password_code_label".tr,
                      hint: "237967",
                      controller: controller.codeController,
                      keyboardType: TextInputType.number,
                      icon: Icon(
                        Icons.password_outlined,
                        size: 22,
                        color: ColorManager.colorPrimary,
                      ),
                      validator: controller.validateCode,
                    ),
                    Obx(
                      () => LabeledTextField(
                        label: "change_password_new".tr,
                        hint: "••••••••",
                        obscureText: controller.obscurePassword.value,
                        controller: controller.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        validator: controller.validatePassword,
                        icon: _passwordIcon(),
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
                        icon: _passwordIcon(),
                        suffixIcon: _eye(
                          controller.obscureConfirmPassword.value,
                          controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.p4),
                    Obx(
                      () => AppButton(
                        text: "common_confirm".tr,
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
