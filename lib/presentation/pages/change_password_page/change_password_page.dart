import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/change_password_page/change_password_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class ChangePasswordPage extends GetView<ChangePasswordPageController> {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: ColorManager.colorBackground,
        appBar: NormalAppBar(
          title: "profile_change_password".tr,
          backIcon: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p12,
                      vertical: AppPadding.p10,
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.colorWhite,
                      borderRadius: BorderRadius.circular(AppSize.s16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: AppSize.s20,
                              color: ColorManager.colorPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "profile_change_password".tr,
                              style: TextStyle(
                                fontSize: FontSize.s15,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.colorFontPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppPadding.p12),
                        Obx(
                          () => CustomTextField(
                            title: "change_password_current".tr,
                            hint: "••••••••",
                            obscureText:
                                controller.obscureCurrentPassword.value,
                            textEditingController:
                                controller.currentPasswordController,
                            textInputType: TextInputType.visiblePassword,
                            fillColor: ColorManager.colorBackground,
                            borderRadius: 10,
                            validator: controller.validateCurrentPassword,
                            suffixIcon: InkWell(
                              onTap: controller.toggleCurrentPasswordVisibility,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Icon(
                                  controller.obscureCurrentPassword.value
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
                            title: "change_password_new".tr,
                            hint: "••••••••",
                            obscureText: controller.obscureNewPassword.value,
                            textEditingController:
                                controller.newPasswordController,
                            textInputType: TextInputType.visiblePassword,
                            fillColor: ColorManager.colorBackground,
                            borderRadius: 10,
                            validator: controller.validateNewPassword,
                            suffixIcon: InkWell(
                              onTap: controller.toggleNewPasswordVisibility,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Icon(
                                  controller.obscureNewPassword.value
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
                            title: "change_password_confirm".tr,
                            hint: "••••••••",
                            obscureText:
                                controller.obscureConfirmPassword.value,
                            textEditingController:
                                controller.confirmPasswordController,
                            textInputType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            fillColor: ColorManager.colorBackground,
                            borderRadius: 10,
                            validator: controller.validateConfirmPassword,
                            suffixIcon: InkWell(
                              onTap: controller.toggleConfirmPasswordVisibility,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppPadding.p12),
                  Obx(
                    () => AppButton(
                      text: "common_save".tr,
                      radius: 12,
                      minHeight: 42,
                      loadingMode:
                          controller.loadingState.value == LoadingState.loading,
                      onPressed: controller.submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
