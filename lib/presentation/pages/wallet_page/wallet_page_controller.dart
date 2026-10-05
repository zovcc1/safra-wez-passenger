import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/wallet_model.dart';
import 'package:safraa_passenger_app/data/models/wallet_transaction_model.dart';
import 'package:safraa_passenger_app/data/repos/wallet_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class WalletPageController extends GetxController {
  final WalletRepo walletRepo = Get.find<WalletRepo>();

  final scrollController = ScrollController();

  // Balance
  final walletState = LoadingState.idle.obs;
  final wallet = Rxn<WalletModel>();
  String? walletError;

  // Ledger
  final txState = LoadingState.idle.obs;
  final loadingMore = false.obs;
  final transactions = <WalletTransactionModel>[].obs;
  String? _nextCursor;
  // يمنع استجابة قديمة (فلتر سابق) من الكتابة فوق نتائج فلتر أحدث.
  int _generation = 0;

  // Filters (applied)
  final selectedTypes = <String>{}.obs;
  final dateRange = Rxn<DateTimeRange>();

  bool get hasFilters => selectedTypes.isNotEmpty || dateRange.value != null;

  static final _apiDate = DateFormat("yyyy-MM-dd");

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([loadWallet(), reloadTransactions()]);
  }

  Future<void> loadWallet() async {
    if (wallet.value == null) walletState.value = LoadingState.loading;
    final response = await walletRepo.wallet();
    if (response.success) {
      wallet.value = response.data;
      walletState.value = LoadingState.doneWithData;
    } else {
      walletError = response.getErrorMessage();
      if (wallet.value == null) {
        walletState.value = LoadingState.hasError;
      } else {
        CustomToasts(message: walletError!, type: CustomToastType.error).show();
      }
    }
  }

  Future<void> reloadTransactions() async {
    _generation++;
    _nextCursor = null;
    loadingMore.value = false;
    txState.value = LoadingState.loading;
    transactions.clear();
    await _fetch();
  }

  Future<void> loadMore() async {
    if (_nextCursor == null ||
        loadingMore.value ||
        txState.value == LoadingState.loading) {
      return;
    }
    loadingMore.value = true;
    final gen = _generation;
    await _fetch();
    if (gen == _generation) loadingMore.value = false;
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final threshold = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= threshold) loadMore();
  }

  Future<void> _fetch() async {
    final gen = _generation;
    final range = dateRange.value;
    final response = await walletRepo.transactions(
      types: selectedTypes.toList(),
      from: range == null ? null : _apiDate.format(range.start),
      to: range == null ? null : _apiDate.format(range.end),
      cursor: _nextCursor,
    );
    if (gen != _generation) return;

    if (!response.success) {
      if (transactions.isEmpty) {
        txState.value = LoadingState.hasError;
      } else {
        CustomToasts(
          message: response.getErrorMessage(),
          type: CustomToastType.error,
        ).show();
      }
      return;
    }

    final page = response.data!;
    transactions.addAll(page.items);
    _nextCursor = page.hasMore ? page.nextCursor : null;
    txState.value = transactions.isEmpty
        ? LoadingState.doneWithNoData
        : LoadingState.doneWithData;
  }

  void applyFilters(Set<String> types, DateTimeRange? range) {
    selectedTypes
      ..clear()
      ..addAll(types);
    dateRange.value = range;
    reloadTransactions();
  }

  void clearFilters() => applyFilters({}, null);

  void openBooking(int bookingId) => Get.toNamed(
    AppRoutes.bookingDetailsRoute,
    arguments: {"bookingId": bookingId},
  );

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
