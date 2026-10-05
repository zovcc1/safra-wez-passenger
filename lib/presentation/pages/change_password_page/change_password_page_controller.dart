import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/dto/change_password_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';

class ChangePasswordPageController extends GetxController {
  final AuthRepo authRepo = Get.find<AuthRepo>();

  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final loadingState = LoadingState.idle.obs;

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty)
      return "change_password_validation_current_required".tr;
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty)
      return "change_password_validation_new_required".tr;
    if (value.length < 8) return "change_password_validation_min_length".tr;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty)
      return "change_password_validation_confirm_required".tr;
    if (value != newPasswordController.text)
      return "change_password_validation_mismatch".tr;
    return null;
  }

  void toggleCurrentPasswordVisibility() =>
      obscureCurrentPassword.value = !obscureCurrentPassword.value;

  void toggleNewPasswordVisibility() =>
      obscureNewPassword.value = !obscureNewPassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (loadingState.value == LoadingState.loading) return;

    loadingState.value = LoadingState.loading;
    final response = await authRepo.changePassword(
      ChangePasswordDto(
        currentPassword: currentPasswordController.text,
        password: newPasswordController.text,
      ),
    );
    loadingState.value = LoadingState.idle;

    if (!response.success) {
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    CustomToasts(
      message: "change_password_success".tr,
      type: CustomToastType.success,
    ).show();
    Get.back();
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
