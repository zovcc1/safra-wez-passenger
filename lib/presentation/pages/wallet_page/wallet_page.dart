import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/wallet_model.dart';
import 'package:safraa_passenger_app/data/models/wallet_transaction_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/info_pill.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/wallet_page/wallet_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/wallet_display.dart';

class WalletPage extends GetView<WalletPageController> {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
      appBar: NormalAppBar(
        title: "wallet_title".tr,
        backIcon: true,
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => _openFilters(context),
              icon: Badge(
                isLabelVisible: controller.hasFilters,
                smallSize: 8,
                child: const Icon(Icons.filter_list_rounded),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: Obx(() => _body(context)),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final txState = controller.txState.value;
    final txs = controller.transactions;

    return CustomScrollView(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppPadding.p16),
          sliver: SliverToBoxAdapter(child: _balanceSection()),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "wallet_transactions_title".tr,
                    style: TextStyle(
                      fontSize: FontSize.s15,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
                if (controller.hasFilters)
                  TextButton(
                    onPressed: controller.clearFilters,
                    child: Text("wallet_filter_clear".tr),
                  ),
              ],
            ),
          ),
        ),
        if (txState == LoadingState.idle || txState == LoadingState.loading)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: SpinKitFadingCircle(
                  color: ColorManager.colorPrimary,
                  size: 42,
                ),
              ),
            ),
          )
        else if (txState == LoadingState.hasError)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ErrorPlaceholderWidget(title: "wallet_tx_error".tr),
            ),
          )
        else if (txState == LoadingState.doneWithNoData)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: "wallet_tx_empty_title".tr,
                subtitle: "wallet_tx_empty_subtitle".tr,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(AppPadding.p16),
            sliver: SliverList.separated(
              itemCount: txs.length + (controller.loadingMore.value ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppPadding.p12),
              itemBuilder: (context, index) {
                if (index >= txs.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppPadding.p16,
                    ),
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: ColorManager.colorPrimary,
                        size: 20,
                      ),
                    ),
                  );
                }
                return _TransactionCard(
                  tx: txs[index],
                  onOpenBooking: controller.openBooking,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _balanceSection() {
    final state = controller.walletState.value;
    if (state == LoadingState.idle || state == LoadingState.loading) {
      return SizedBox(
        height: 150,
        child: Center(
          child: SpinKitFadingCircle(
            color: ColorManager.colorPrimary,
            size: 36,
          ),
        ),
      );
    }
    if (state == LoadingState.hasError || controller.wallet.value == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12,
          vertical: AppPadding.p10,
        ),
        decoration: BoxDecoration(
          color: ColorManager.colorWhite,
          borderRadius: BorderRadius.circular(AppSize.s16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: ColorManager.colorError300),
            const SizedBox(width: AppPadding.p12),
            Expanded(
              child: Text(
                controller.walletError ?? "wallet_error".tr,
                style: TextStyle(fontSize: FontSize.s13),
              ),
            ),
            TextButton(
              onPressed: controller.loadWallet,
              child: Text("wallet_retry".tr),
            ),
          ],
        ),
      );
    }
    return FadeSlideIn(child: _BalanceCard(wallet: controller.wallet.value!));
  }

  Future<void> _openFilters(BuildContext context) async {
    final types = Set<String>.from(controller.selectedTypes);
    DateTimeRange? range = controller.dateRange.value;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorManager.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.s16)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "wallet_filter_title".tr,
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
                const SizedBox(height: AppPadding.p16),
                Text(
                  "wallet_filter_type".tr,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    color: ColorManager.colorGrey6,
                  ),
                ),
                const SizedBox(height: AppPadding.p8),
                Wrap(
                  spacing: AppPadding.p8,
                  runSpacing: AppPadding.p8,
                  children: [
                    for (final type in WalletTypeDisplay.allTypes)
                      _TypePill(
                        label: WalletTypeDisplay.of(type).label,
                        selected: types.contains(type),
                        onTap: () => setState(() {
                          types.contains(type)
                              ? types.remove(type)
                              : types.add(type);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: AppPadding.p16),
                Text(
                  "wallet_filter_dates".tr,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    color: ColorManager.colorGrey6,
                  ),
                ),
                const SizedBox(height: AppPadding.p8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 5),
                      lastDate: now,
                      initialDateRange: range,
                    );
                    if (picked != null) setState(() => range = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.colorBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range_outlined,
                          size: AppSize.s18,
                          color: ColorManager.colorGrey6,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            range == null
                                ? "wallet_filter_pick_dates".tr
                                : "${DateConverter.dateUTCToString(range!.start)}  →  ${DateConverter.dateUTCToString(range!.end)}",
                            style: TextStyle(
                              fontSize: FontSize.s13,
                              fontWeight: FontWeight.w600,
                              color: range == null
                                  ? ColorManager.colorDoveGray300
                                  : ColorManager.colorFontPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (range != null)
                  TextButton(
                    onPressed: () => setState(() => range = null),
                    child: Text("wallet_filter_clear_dates".tr),
                  ),
                const SizedBox(height: AppPadding.p16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: "wallet_filter_reset".tr,
                        backgroundColor: ColorManager.colorBackground,
                        fontColor: ColorManager.colorFontPrimary,
                        radius: 12,
                        minHeight: 42,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          controller.clearFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: AppPadding.p12),
                    Expanded(
                      child: AppButton(
                        text: "wallet_filter_apply".tr,
                        radius: 12,
                        minHeight: 42,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          controller.applyFilters(types, range);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet});

  final WalletModel wallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.colorPrimary,
        borderRadius: BorderRadius.circular(AppSize.s16),
        boxShadow: [
          BoxShadow(
            color: ColorManager.colorPrimary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: AppSize.s20,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                "wallet_available_balance".tr,
                style: TextStyle(fontSize: FontSize.s13, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.p4),
          Text(
            "${wallet.balance} ${wallet.currency}",
            style: TextStyle(
              fontSize: FontSize.s22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppPadding.p12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: AppPadding.p8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: "wallet_frozen_balance".tr,
                    value: "${wallet.frozenBalance} ${wallet.currency}",
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: "wallet_total_balance".tr,
                    value: "${wallet.totalBalance} ${wallet.currency}",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? ColorManager.colorPrimary.withValues(alpha: 0.12)
              : ColorManager.colorBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? ColorManager.colorPrimary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            color: selected
                ? ColorManager.colorPrimary
                : ColorManager.colorGrey6,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: FontSize.s11, color: Colors.white70),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.tx, required this.onOpenBooking});

  final WalletTransactionModel tx;
  final void Function(int bookingId) onOpenBooking;

  @override
  Widget build(BuildContext context) {
    final display = WalletTypeDisplay.of(tx.type);
    final ref = tx.reference;
    final refId = ref?.id;
    final canOpenBooking = ref?.type == "booking" && refId != null;
    final sign = WalletTypeDisplay.signOf(tx.direction);
    final amountColor = tx.direction == "credit"
        ? ColorManager.colorGreen3
        : tx.direction == "debit"
        ? ColorManager.colorError300
        : ColorManager.colorFontPrimary;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: ColorManager.colorWhite,
          borderRadius: BorderRadius.circular(AppSize.s16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSize.s16),
          onTap: canOpenBooking ? () => onOpenBooking(refId) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: AppPadding.p10,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: display.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(display.icon, color: display.color, size: 18),
                ),
                const SizedBox(width: AppPadding.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        display.label,
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: AppPadding.p8,
                        runSpacing: 6,
                        children: [
                          if (ref != null)
                            InfoPill(
                              icon: Icons.tag,
                              text: refId == null
                                  ? WalletTypeDisplay.referenceLabel(ref.type)
                                  : "${WalletTypeDisplay.referenceLabel(ref.type)} #$refId",
                            ),
                          InfoPill(
                            icon: Icons.schedule_outlined,
                            text:
                                "${DateConverter.dateToStringAR(tx.createdAt)} • ${DateConverter.timeUTCToString(tx.createdAt)}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppPadding.p8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$sign${tx.amount}",
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: FontSize.s15,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "wallet_balance_after".trParams({
                        "amount": tx.balanceAfter,
                      }),
                      style: TextStyle(
                        fontSize: FontSize.s10_5,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
