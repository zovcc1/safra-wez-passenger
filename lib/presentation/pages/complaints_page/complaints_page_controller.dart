import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/complaint_model.dart';
import 'package:safraa_passenger_app/data/repos/complaints_repo.dart';
import 'package:safraa_passenger_app/data/repos/reference_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class ComplaintsPageController extends GetxController {
  final ComplaintsRepo complaintsRepo = Get.find<ComplaintsRepo>();
  final ReferenceRepo referenceRepo = Get.find<ReferenceRepo>();

  final scrollController = ScrollController();

  final loadingState = LoadingState.idle.obs;
  final loadingMore = false.obs;
  final complaints = <ComplaintModel>[].obs;

  /// key → اسم التصنيف بلغة التطبيق. فارغ إلى أن تُحمَّل التصنيفات (fallback:
  /// نعرض المفتاح الخام).
  final categoryLabels = <String, String>{}.obs;

  String? _nextCursor;

  bool get _hasMore => _nextCursor != null;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _loadCategories();
    reload();
  }

  Future<void> _loadCategories() async {
    final response = await referenceRepo.complaintCategories();
    if (!response.success) return;
    categoryLabels.value = {
      for (final c in response.data!)
        c.key: c.labelFor(AppTranslations.currentLang),
    };
  }

  Future<void> reload() async {
    _nextCursor = null;
    loadingState.value = LoadingState.loading;
    complaints.clear();
    await _fetch();
  }

  Future<void> loadMore() async {
    if (!_hasMore ||
        loadingMore.value ||
        loadingState.value == LoadingState.loading) {
      return;
    }
    loadingMore.value = true;
    await _fetch();
    loadingMore.value = false;
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final threshold = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= threshold) loadMore();
  }

  Future<void> _fetch() async {
    final response = await complaintsRepo.list(cursor: _nextCursor);

    if (!response.success) {
      if (complaints.isEmpty) {
        loadingState.value = LoadingState.hasError;
      } else {
        CustomToasts(
          message: response.getErrorMessage(),
          type: CustomToastType.error,
        ).show();
      }
      return;
    }

    final page = response.data!;
    complaints.addAll(page.items);
    // الـ cursor لا يُفسَّر: نكمّل طالما has_more=true.
    _nextCursor = page.hasMore ? page.nextCursor : null;
    loadingState.value = complaints.isEmpty
        ? LoadingState.doneWithNoData
        : LoadingState.doneWithData;
  }

  Future<void> fileNew() async {
    final created = await Get.toNamed(AppRoutes.fileComplaintRoute);
    if (created != null) reload();
  }

  void openDetails(ComplaintModel complaint) async {
    await Get.toNamed(
      AppRoutes.complaintDetailsRoute,
      arguments: {"complaintId": complaint.complaintId},
    );
    // الحالة قد تتغير أثناء المحادثة (in_progress/resolved).
    reload();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
