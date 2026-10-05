import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/notification_models.dart';
import 'package:safraa_passenger_app/data/repos/notifications_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/notification_router.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class NotificationsPageController extends GetxController {
  final NotificationsRepo repo = Get.find<NotificationsRepo>();

  final scrollController = ScrollController();

  final loadingState = LoadingState.idle.obs;
  final loadingMore = false.obs;
  final items = <NotificationItemModel>[].obs;

  /// null = الكل، أو "unread".
  final statusFilter = RxnString();

  String? _nextCursor;
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
    items.clear();
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
    // استجابة قديمة (فلتر سابق) لا تكتب فوق نتائج فلتر أحدث.
    if (generation != _generation) return;

    if (!response.success) {
      if (items.isEmpty) {
        loadingState.value = LoadingState.hasError;
      } else {
        CustomToasts(
          message: response.getErrorMessage(),
          type: CustomToastType.error,
        ).show();
      }
      return;
    }
    items.addAll(response.data!.items);
    _nextCursor = response.data!.nextCursor;
    loadingState.value = items.isEmpty
        ? LoadingState.doneWithNoData
        : LoadingState.doneWithData;
  }

  /// قد يشير الإشعار لشيء محذوف أو لنوع بلا شاشة: نبقى بالصندوق بدل شاشة فارغة.
  void open(NotificationItemModel item) {
    _markRead(item);
    NotificationRouter.open(item.type, item.data);
  }

  /// تحديث متفائل؛ العملية idempotent فلا ضرر من التكرار، ونتراجع عند الفشل.
  Future<void> _markRead(NotificationItemModel item) async {
    if (item.isRead) return;
    item.isRead = true;
    items.refresh();
    final response = await repo.markRead(item.notificationId);
    if (!response.success) {
      item.isRead = false;
      items.refresh();
    }
  }

  void openSettings() => Get.toNamed(AppRoutes.notificationSettingsRoute);

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
