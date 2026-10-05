import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/data/repos/bookings_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';

class BookingsPageController extends GetxController {
  final BookingsRepo bookingsRepo = Get.find<BookingsRepo>();

  final scrollController = ScrollController();

  final loadingState = LoadingState.idle.obs;
  final loadingMore = false.obs;
  final bookings = <BookingModel>[].obs;
  String? _nextCursor;

  bool get _hasMore => _nextCursor != null;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    reload();
  }

  Future<void> reload() async {
    _nextCursor = null;
    loadingState.value = LoadingState.loading;
    bookings.clear();
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
    if (scrollController.position.pixels >= threshold) {
      loadMore();
    }
  }

  Future<void> _fetch() async {
    final response = await bookingsRepo.list(cursor: _nextCursor);

    if (!response.success) {
      if (bookings.isEmpty) {
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
    bookings.addAll(page.items);
    _nextCursor = page.nextCursor;
    loadingState.value = bookings.isEmpty
        ? LoadingState.doneWithNoData
        : LoadingState.doneWithData;
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
