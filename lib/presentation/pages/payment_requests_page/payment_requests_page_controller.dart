import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/payment_request_model.dart';
import 'package:safraa_passenger_app/data/repos/payment_requests_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class PaymentRequestsPageController extends GetxController {
  final PaymentRequestsRepo repo = Get.find<PaymentRequestsRepo>();

  final scrollController = ScrollController();

  final loadingState = LoadingState.idle.obs;
  final loadingMore = false.obs;
  final requests = <PaymentRequestModel>[].obs;

  /// null = الكل، أو pending/approved/rejected/expired/cancelled.
  final statusFilter = RxnString();

  String? _nextCursor;
  // يمنع استجابة قديمة (فلتر سابق) من الكتابة فوق نتائج فلتر أحدث.
  int _generation = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    reload();
  }

  void setFilter(String? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    reload();
  }

  Future<void> reload() async {
    _nextCursor = null;
    loadingState.value = LoadingState.loading;
    requests.clear();
    await _fetch();
  }

  Future<void> loadMore() async {
    if (_nextCursor == null ||
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
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> _fetch() async {
    final generation = ++_generation;
    final response = await repo.list(
      cursor: _nextCursor,
      status: statusFilter.value,
    );
    if (generation != _generation) return;

    if (!response.success) {
      if (requests.isEmpty) {
        loadingState.value = LoadingState.hasError;
      } else {
        CustomToasts(
          message: response.getErrorMessage(),
          type: CustomToastType.error,
        ).show();
      }
      return;
    }
    requests.addAll(response.data!.items);
    _nextCursor = response.data!.nextCursor;
    loadingState.value = requests.isEmpty
        ? LoadingState.doneWithNoData
        : LoadingState.doneWithData;
  }

  /// بعد الرجوع من التفاصيل نعيد التحميل: قد تكون الحالة تغيّرت (موافقة/رفض).
  Future<void> open(PaymentRequestModel request) async {
    await Get.toNamed(
      AppRoutes.paymentRequestDetailsRoute,
      arguments: {"paymentRequestId": request.paymentRequestId},
    );
    reload();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
