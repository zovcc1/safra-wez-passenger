import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
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
        backgroundColor: Colors.transparent,
        appBar: NormalAppBar(
          title: "profile_change_password".tr,
          backIcon: true,
        ),
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: AppPadding.p10,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.colorWhite,
                          borderRadius: BorderRadius.circular(AppSize.s16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: ColorManager.colorPrimary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: ColorManager.colorPrimary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "profile_change_password".tr,
                                  style: TextStyle(
                                    fontSize: FontSize.s15,
                                    fontWeight: FontWeight.w500,
                                    color: ColorManager.colorFontPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppPadding.p12),
                            _PasswordField(
                              label: "change_password_current".tr,
                              textController:
                                  controller.currentPasswordController,
                              obscure: controller.obscureCurrentPassword,
                              onToggle:
                                  controller.toggleCurrentPasswordVisibility,
                              validator: controller.validateCurrentPassword,
                            ),
                            const SizedBox(height: AppPadding.p12),
                            _PasswordField(
                              label: "change_password_new".tr,
                              textController: controller.newPasswordController,
                              obscure: controller.obscureNewPassword,
                              onToggle: controller.toggleNewPasswordVisibility,
                              validator: controller.validateNewPassword,
                            ),
                            const SizedBox(height: AppPadding.p12),
                            _PasswordField(
                              label: "change_password_confirm".tr,
                              textController:
                                  controller.confirmPasswordController,
                              obscure: controller.obscureConfirmPassword,
                              onToggle:
                                  controller.toggleConfirmPasswordVisibility,
                              validator: controller.validateConfirmPassword,
                              isLast: true,
                            ),
                            const SizedBox(height: AppPadding.p4),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.p8),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: Obx(
                        () => AppButton(
                          text: "common_save".tr,
                          radius: 12,
                          minHeight: 42,
                          loadingMode:
                              controller.loadingState.value ==
                              LoadingState.loading,
                          onPressed: controller.submit,
                        ),
                      ),
                    ),
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

/// حقل كلمة مرور بنفس طراز حقول البحث في الرحلات: تسمية فوق الحقل، حقل أبيض
/// بحدّ رفيع وارتفاع 42 وأيقونة قفل في البداية.
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.textController,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    this.isLast = false,
  });

  final String label;
  final TextEditingController textController;
  final RxBool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w500,
              color: ColorManager.colorDoveGray600,
            ),
          ),
        ),
        Obx(
          () => CustomTextField(
            title: null,
            hint: "••••••••",
            icon: Icon(
              Icons.lock_outline_rounded,
              size: 22,
              color: ColorManager.colorPrimary,
            ),
            obscureText: obscure.value,
            textEditingController: textController,
            textInputType: TextInputType.visiblePassword,
            textInputAction: isLast
                ? TextInputAction.done
                : TextInputAction.next,
            fillColor: ColorManager.colorWhite,
            borderRadius: 10,
            minHeight: 42,
            fontColor: ColorManager.colorFontPrimary,
            fontWeight: FontWeight.w500,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: 10,
            ),
            validator: validator,
            suffixIcon: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  obscure.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 22,
                  color: ColorManager.colorGrey6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
