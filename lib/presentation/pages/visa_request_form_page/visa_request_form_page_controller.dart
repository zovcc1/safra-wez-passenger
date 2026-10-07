import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/dto/submit_visa_request_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_document_model.dart';
import 'package:safraa_passenger_app/data/models/visa_field_model.dart';
import 'package:safraa_passenger_app/data/models/visa_form_model.dart';
import 'package:safraa_passenger_app/data/models/visa_request_model.dart';
import 'package:safraa_passenger_app/data/repos/visa_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';

enum VisaFormMode { create, resubmit, edit }

class VisaRequestFormPageController extends GetxController {
  final VisaRepo visaRepo = Get.find<VisaRepo>();

  late final VisaFormMode mode;
  late final int countryId;
  int? requestId;

  final loadingState = LoadingState.idle.obs;
  final submitting = false.obs;
  final Rxn<VisaFormModel> form = Rxn<VisaFormModel>();

  // السعر المعروض للمستخدم: يأتي من قائمة الدول (price) لأن نموذج الدولة لا
  // يحمل سعرًا — يُحدَّث بعد تأكيد تغيّر السعر (409 بوضع create فقط).
  final expectedPrice = "".obs;

  final Map<int, TextEditingController> textControllers = {};
  final Map<int, Rxn<File>> fileValues = {};

  /// الملفات المرفوعة سابقًا بوضعي التعديل وإعادة الإرسال (حسب field_id).
  /// تبقى كما هي على الخادم ما لم يختر المستخدم ملفًا جديدًا.
  final Map<int, VisaDocumentModel> existingDocuments = {};
  final Set<int> touchedFields = {};

  final fieldErrors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    mode = VisaFormMode.values.firstWhere(
      (m) => m.name == args["mode"],
      orElse: () => VisaFormMode.create,
    );
    countryId = args["countryId"] as int;
    requestId = args["requestId"] as int?;
    expectedPrice.value = args["price"]?.toString() ?? "";
    _loadForm();
  }

  Future<void> _loadForm() async {
    loadingState.value = LoadingState.loading;
    fieldErrors.clear();
    for (final c in textControllers.values) {
      c.dispose();
    }
    textControllers.clear();
    fileValues.clear();
    existingDocuments.clear();
    touchedFields.clear();
    final response = await visaRepo.form(countryId);
    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    final loadedForm = response.data!;
    form.value = loadedForm;

    for (final field in loadedForm.fields) {
      if (field.type == "file") {
        fileValues[field.fieldId] = Rxn<File>();
      } else {
        textControllers[field.fieldId] = TextEditingController();
      }
    }

    // وضعا التعديل وإعادة الإرسال: تُعبَّأ الحقول بقيم الطلب الحالي، وإلا
    // يظهر النموذج فارغًا ويبدو كأن البيانات ضاعت.
    if (mode != VisaFormMode.create && requestId != null) {
      final current = await visaRepo.details(requestId!);
      if (!current.success) {
        loadingState.value = LoadingState.hasError;
        CustomToasts(
          message: current.getErrorMessage(),
          type: CustomToastType.error,
        ).show();
        return;
      }
      _prefill(current.data!, loadedForm);
    }

    loadingState.value = LoadingState.doneWithData;
  }

  /// لا تُعلَّم الحقول كـ touched: غير الملموسة لا تُرسل، فلا يُعاد رفع
  /// قيم لم يغيّرها المستخدم.
  void _prefill(VisaRequestModel request, VisaFormModel loadedForm) {
    for (final field in loadedForm.fields) {
      if (field.type == "file") {
        final doc = request.documents
            .where((d) => d.fieldId == field.fieldId)
            .firstOrNull;
        if (doc != null) existingDocuments[field.fieldId] = doc;
      } else {
        textControllers[field.fieldId]?.text =
            request.values[field.fieldId] ?? "";
      }
    }
  }

  void onTextChanged(int fieldId, String value) => touchedFields.add(fieldId);

  /// date (YYYY-MM-DD) وselect (نص الخيار en) يُخزَّنان بنفس متحكّم النص.
  void setFieldText(int fieldId, String value) {
    touchedFields.add(fieldId);
    textControllers[fieldId]?.text = value;
  }

  void setFile(int fieldId, File? file) {
    touchedFields.add(fieldId);
    fileValues[fieldId]?.value = file;
  }

  /// يطابق أشكال مفاتيح errors المحتملة (field_key أو field_id، بادئة fields.
  /// أو بدونها) بدل افتراض شكل واحد — راجع القسم 6 بالخطة.
  String? fieldError(VisaFieldModel field) {
    final candidates = [
      "fields.${field.fieldKey}",
      "fields.${field.fieldId}",
      field.fieldKey,
      "${field.fieldId}",
    ];
    for (final key in candidates) {
      final message = fieldErrors[key];
      if (message != null) return message;
    }
    return null;
  }

  bool _validateCreate(VisaFormModel loadedForm) {
    var valid = true;
    for (final field in loadedForm.fields) {
      if (!field.required) continue;
      final hasValue = field.type == "file"
          ? fileValues[field.fieldId]?.value != null
          : (textControllers[field.fieldId]?.text.trim().isNotEmpty ?? false);
      if (!hasValue) valid = false;
    }
    return valid;
  }

  SubmitVisaRequestDto _buildDto(VisaFormModel loadedForm) {
    final values = <int, String>{};
    final files = <int, File>{};

    for (final field in loadedForm.fields) {
      final isTouched =
          mode == VisaFormMode.create || touchedFields.contains(field.fieldId);
      if (!isTouched) continue;

      if (field.type == "file") {
        final file = fileValues[field.fieldId]?.value;
        if (file != null) files[field.fieldId] = file;
      } else {
        final text = textControllers[field.fieldId]?.text ?? "";
        // بوضع create لا تُرسل حقول نصية فارغة غير مطلوبة، لكن بوضعي
        // resubmit/edit القيمة الفارغة الملموسة صراحةً تعني "امسح الإجابة"،
        // فتُرسل كما هي.
        if (mode == VisaFormMode.create && text.trim().isEmpty) continue;
        values[field.fieldId] = text;
      }
    }

    return SubmitVisaRequestDto(
      countryId: mode == VisaFormMode.create ? countryId : null,
      templateId: mode == VisaFormMode.create ? loadedForm.templateId : null,
      expectedPrice: mode == VisaFormMode.create ? expectedPrice.value : null,
      values: values,
      files: files,
    );
  }

  Future<void> submit() async {
    final loadedForm = form.value;
    if (loadedForm == null || submitting.value) return;

    fieldErrors.clear();

    if (mode == VisaFormMode.create && !_validateCreate(loadedForm)) {
      CustomToasts(
        message: "visa_form_validation_required".tr,
        type: CustomToastType.warning,
      ).show();
      return;
    }

    submitting.value = true;
    final dto = _buildDto(loadedForm);

    final response = switch (mode) {
      VisaFormMode.create => await visaRepo.create(dto),
      VisaFormMode.resubmit => await visaRepo.resubmit(requestId!, dto),
      VisaFormMode.edit => await visaRepo.update(requestId!, dto),
    };
    submitting.value = false;

    if (!response.success) {
      _handleFailure(response.fieldErrors, response.networkFailure?.code);
      return;
    }

    CustomToasts(
      message: "visa_form_submit_success".tr,
      type: CustomToastType.success,
    ).show();
    Get.offNamed(
      AppRoutes.visaRequestDetailsRoute,
      arguments: {"requestId": response.data!.id},
    );
  }

  void _handleFailure(
    Map<String, List<String>>? serverFieldErrors,
    int? statusCode,
  ) {
    if (serverFieldErrors != null) {
      fieldErrors.assignAll(
        serverFieldErrors.map((key, value) => MapEntry(key, value.first)),
      );
    }

    // PATCH بوضع edit: 409 هنا يعني الأدمن فتح الطلب باللحظة نفسها، وهو أمر
    // مختلف تمامًا عن تعارض السعر بالإنشاء (الذي لا يحدث إلا بوضع create) —
    // لا معنى لإعادة المحاولة، فقط نُعلم المستخدم ونعيده لشاشة التفاصيل
    // المحدَّثة. نميّز الحالة بكود 409 نفسه (networkFailure.code) لا بشكل
    // fieldErrors، لأن PATCH لا يرجع مفهوم current_price/expected_price إطلاقًا.
    if (mode == VisaFormMode.edit && statusCode == 409) {
      CustomToasts(
        message: "visa_form_edit_locked".tr,
        type: CustomToastType.warning,
      ).show();
      Get.offNamed(
        AppRoutes.visaRequestDetailsRoute,
        arguments: {"requestId": requestId},
      );
      return;
    }

    if (mode == VisaFormMode.create && statusCode == 409) {
      if (fieldErrors.containsKey("current_price")) {
        _promptPriceChange();
      } else {
        // 409 بلا current_price = النموذج تحدّث أثناء التعبئة: نعيد تحميله.
        CustomToasts(
          message: "visa_form_template_changed".tr,
          type: CustomToastType.warning,
        ).show();
        _loadForm();
      }
      return;
    }

    CustomToasts(
      message: fieldErrors.isEmpty
          ? "visa_form_submit_error".tr
          : "visa_form_validation_error".tr,
      type: CustomToastType.error,
    ).show();
  }

  void _promptPriceChange() {
    final newPrice = (fieldErrors["current_price"] ?? "").trim();
    if (newPrice.isNotEmpty) expectedPrice.value = newPrice;

    Get.dialog(
      _PriceChangeDialog(newPrice: expectedPrice.value, onConfirm: submit),
    );
  }

  @override
  void onClose() {
    for (final c in textControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}

class _PriceChangeDialog extends StatelessWidget {
  const _PriceChangeDialog({required this.newPrice, required this.onConfirm});

  final String newPrice;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManager.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "visa_form_price_changed_title".tr,
              style: TextStyle(
                fontSize: FontSize.s16,
                fontWeight: FontWeight.bold,
                color: ColorManager.colorFontPrimary,
              ),
            ),
            const SizedBox(height: AppPadding.p8),
            Text(
              "visa_form_price_changed_message".trParams({
                "price": Money.format(newPrice),
              }),
              style: TextStyle(
                fontSize: FontSize.s13,
                color: ColorManager.colorGrey6,
              ),
            ),
            const SizedBox(height: AppPadding.p20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: "common_cancel".tr,
                    backgroundColor: ColorManager.colorTextFieldFill,
                    fontColor: ColorManager.colorFontPrimary,
                    radius: 12,
                    onPressed: Get.back,
                  ),
                ),
                const SizedBox(width: AppPadding.p12),
                Expanded(
                  child: AppButton(
                    text: "common_confirm".tr,
                    radius: 12,
                    onPressed: () {
                      Get.back();
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
