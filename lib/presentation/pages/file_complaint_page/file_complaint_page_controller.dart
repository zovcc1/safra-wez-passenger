import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/dto/file_complaint_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/complaint_category_model.dart';
import 'package:safraa_passenger_app/data/repos/complaints_repo.dart';
import 'package:safraa_passenger_app/data/repos/reference_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';

class FileComplaintPageController extends GetxController {
  static const int descriptionMaxLength = 2000;

  final ComplaintsRepo complaintsRepo = Get.find<ComplaintsRepo>();
  final ReferenceRepo referenceRepo = Get.find<ReferenceRepo>();

  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();

  /// اختياري: يُمرَّر من تفاصيل الحجز لربط الشكوى بحجز المسافر.
  int? bookingId;

  final categoriesState = LoadingState.idle.obs;
  final categories = <ComplaintCategoryModel>[].obs;
  final selectedCategory = RxnString();
  final categoryError = false.obs;
  final submitting = false.obs;

  String get lang => AppTranslations.currentLang;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) bookingId = args["bookingId"] as int?;
    loadCategories();
  }

  Future<void> loadCategories() async {
    categoriesState.value = LoadingState.loading;
    final response = await referenceRepo.complaintCategories();
    if (!response.success) {
      categoriesState.value = LoadingState.hasError;
      return;
    }
    categories.value = response.data!;
    categoriesState.value = LoadingState.doneWithData;
  }

  void selectCategory(String key) {
    selectedCategory.value = key;
    categoryError.value = false;
  }

  String? validateDescription(String? value) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) return "file_complaint_description_required".tr;
    if (text.length > descriptionMaxLength) {
      return "file_complaint_description_too_long".tr;
    }
    return null;
  }

  Future<void> submit() async {
    if (submitting.value) return;
    final formValid = formKey.currentState?.validate() ?? false;
    if (selectedCategory.value == null) categoryError.value = true;
    if (!formValid || selectedCategory.value == null) return;

    submitting.value = true;
    final response = await complaintsRepo.file(
      FileComplaintDto(
        category: selectedCategory.value!,
        description: descriptionController.text,
        bookingId: bookingId,
      ),
    );
    submitting.value = false;

    if (!response.success) {
      // 429 (5 شكاوى كل 10 دقائق) و404 (حجز ليس للمسافر) و422 ترجع رسالتها
      // مترجمة من الخادم.
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    CustomToasts(
      message: "file_complaint_success".tr,
      type: CustomToastType.success,
    ).show();
    Get.back(result: response.data);
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}
