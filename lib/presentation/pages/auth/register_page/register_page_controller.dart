import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/data/dto/register_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class RegisterPageController extends GetxController {
  final AuthRepo authRepo = Get.find<AuthRepo>();
  final CacheService cacheService = Get.find<CacheService>();

  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// كود الدولة الحالي (يتغيّر عند اختيار المستخدم دولة أخرى من القائمة)
  final countryCode = "+963".obs;

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final loadingState = LoadingState.idle.obs;
  final fieldErrors = <String, String>{}.obs;

  /// Validator بصيغة IntlPhoneField (يستقبل PhoneNumber؟ وليس String؟)
  String? phoneValidator(PhoneNumber? phone) {
    if (phone == null || phone.number.trim().isEmpty) {
      return "auth_validation_phone_required".tr;
    }
    final phoneNo = phone.number.replaceAll(" ", "");
    if (phoneNo.length != 9 || phoneNo[0] == "0") {
      return "auth_validation_phone_invalid".tr;
    }
    return fieldErrors["phone_number"];
  }

  /// يُستدعى أثناء الكتابة عبر PhoneNumberFormatter (تنسيق العرض فقط، لا حاجة لتخزين شيء هنا)
  void onPhoneChanged(String value) {}

  static final _nationalIdRegExp = RegExp(r'^\d{10,11}$');

  String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty)
      return "auth_validation_national_id_required".tr;
    if (!_nationalIdRegExp.hasMatch(value.trim())) {
      return "auth_validation_national_id_invalid".tr;
    }
    return fieldErrors["national_id"];
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty)
      return "auth_validation_full_name_required".tr;
    return fieldErrors["full_name"];
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty)
      return "auth_validation_password_required".tr;
    if (value.length < 8) return "change_password_validation_min_length".tr;
    return fieldErrors["password"];
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty)
      return "change_password_validation_confirm_required".tr;
    if (value != passwordController.text) {
      return "change_password_validation_mismatch".tr;
    }
    return null;
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  Future<void> register() async {
    fieldErrors.clear();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (loadingState.value == LoadingState.loading) return;

    loadingState.value = LoadingState.loading;

    final localPhoneNumber =
        "0${phoneController.text.trim().replaceAll(' ', '')}";

    final response = await authRepo.register(
      RegisterDto(
        phoneNumber: localPhoneNumber,
        nationalId: nationalIdController.text.trim(),
        fullName: fullNameController.text.trim(),
        password: passwordController.text,
      ),
    );

    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
        fieldErrors.assignAll(
          response.fieldErrors!.map((key, value) => MapEntry(key, value.first)),
        );
        formKey.currentState?.validate();
      } else {
        CustomToasts(
          message: response.getErrorMessage(),
          type: CustomToastType.error,
        ).show();
      }
      return;
    }

    loadingState.value = LoadingState.doneWithData;
    await cacheService.storePendingOtpPhone(localPhoneNumber);
    Get.offAllNamed(
      AppRoutes.verifyOtpRoute,
      arguments: {"phoneNumber": localPhoneNumber, "fromRegister": true},
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    nationalIdController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
