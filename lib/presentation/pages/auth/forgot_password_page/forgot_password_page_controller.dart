import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:safraa_passenger_app/data/dto/forgot_password_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class ForgotPasswordPageController extends GetxController {
  final AuthRepo authRepo = Get.find<AuthRepo>();

  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final loadingState = LoadingState.idle.obs;

  /// كود الدولة الحالي (يتغيّر عند اختيار المستخدم دولة أخرى من القائمة)
  final countryCode = "+963".obs;

  /// Validator بصيغة IntlPhoneField (يستقبل PhoneNumber؟ وليس String؟)
  String? phoneValidator(PhoneNumber? phone) {
    if (phone == null || phone.number.trim().isEmpty) {
      return "auth_validation_phone_required".tr;
    }
    final phoneNo = phone.number.replaceAll(" ", "");
    if (phoneNo.length != 9 || phoneNo[0] == "0") {
      return "auth_validation_phone_invalid".tr;
    }
    return null;
  }

  /// يُستدعى أثناء الكتابة عبر PhoneNumberFormatter (تنسيق العرض فقط، لا حاجة لتخزين شيء هنا)
  void onPhoneChanged(String value) {}

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (loadingState.value == LoadingState.loading) return;

    loadingState.value = LoadingState.loading;
    final phone = "0${phoneController.text.trim().replaceAll(' ', '')}";

    final response = await authRepo.forgotPassword(
      ForgotPasswordDto(phoneNumber: phone),
    );

    // الاستجابة 200 دائمًا بغض النظر عن وجود الرقم فعليًا (لا تسريب لوجود
    // الحساب)؛ الانتقال يحدث دائمًا لشاشة إعادة التعيين بعد نجاح الاستدعاء.
    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    loadingState.value = LoadingState.doneWithData;
    Get.toNamed(
      AppRoutes.resetPasswordRoute,
      arguments: {"phoneNumber": phone},
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
