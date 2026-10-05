import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/dto/reset_password_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class ResetPasswordPageController extends GetxController {
  final AuthRepo authRepo = Get.find<AuthRepo>();

  late final String phoneNumber;

  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final loadingState = LoadingState.idle.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    phoneNumber = (args is Map ? args["phoneNumber"] as String? : null) ?? "";
  }

  String? validateCode(String? value) {
    if (value == null || value.trim().isEmpty)
      return "reset_password_validation_code_required".tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty)
      return "auth_validation_password_required".tr;
    if (value.length < 8) return "change_password_validation_min_length".tr;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty)
      return "change_password_validation_confirm_required".tr;
    if (value != passwordController.text)
      return "change_password_validation_mismatch".tr;
    return null;
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (loadingState.value == LoadingState.loading) return;

    loadingState.value = LoadingState.loading;

    final response = await authRepo.resetPassword(
      ResetPasswordDto(
        phoneNumber: phoneNumber,
        code: codeController.text.trim(),
        password: passwordController.text,
      ),
    );

    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    // كل الجلسات القديمة أُلغيت على الخادم — التوجيه دائمًا لشاشة الدخول.
    loadingState.value = LoadingState.doneWithData;
    Get.offAllNamed(AppRoutes.loginRoute);
  }

  @override
  void onClose() {
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
