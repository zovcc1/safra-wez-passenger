import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/wallet_model.dart';
import 'package:safraa_passenger_app/data/models/wallet_transaction_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/wallet_page/wallet_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/wallet_display.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class WalletPage extends GetView<WalletPageController> {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NormalAppBar(title: "wallet_title".tr, backIcon: true),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshAll,
            child: Obx(() => _body(context)),
          ),
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
            // ارتفاع ثابت كي لا يتحرك زر الفلتر عند ظهور/اختفاء زر "مسح".
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "wallet_transactions_title".tr,
                      style: TextStyle(
                        fontSize: FontSize.s15,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                  ),
                  if (controller.hasFilters)
                    TextButton(
                      onPressed: controller.clearFilters,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(
                        "wallet_filter_clear".tr,
                        style: TextStyle(fontSize: FontSize.s12),
                      ),
                    ),
                  const SizedBox(width: 4),
                  _FilterButton(
                    active: controller.hasFilters,
                    onTap: () => _openFilters(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (txState == LoadingState.idle || txState == LoadingState.loading)
          const SliverFillRemaining(hasScrollBody: false, child: AppLoader())
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
              separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p8),
              itemBuilder: (context, index) {
                if (index >= txs.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppPadding.p16,
                    ),
                    child: Center(child: AppLoader.dots(size: 20)),
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
      return SizedBox(height: 150, child: Center(child: AppLoader(size: 36)));
    }
    if (state == LoadingState.hasError || controller.wallet.value == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppPadding.p10,
        ),
        decoration: BoxDecoration(
          color: ColorManager.colorWhite,
          borderRadius: BorderRadius.circular(AppSize.s16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
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
                    fontWeight: FontWeight.w500,
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
                      color: ColorManager.colorWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ColorManager.colorTextFieldEnabledBorder,
                      ),
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
                              fontWeight: FontWeight.w500,
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

/// زر الفلتر بإطار، يجلس في نفس صف عنوان "الحركات".
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? ColorManager.colorPrimary
        : ColorManager.colorTextFieldEnabledBorder;
    return Material(
      color: ColorManager.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.tune_rounded,
            size: 19,
            color: active
                ? ColorManager.colorPrimary
                : ColorManager.colorFontPrimary,
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
    // لون خاص ببطاقة الرصيد (تيل) لتتمايز عن اللون الأساسي للتطبيق.
    const primary = Color(0xFF0E7C86);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.s16),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            primary,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.22), primary),
          ],
        ),
        // الوهج الملوّن يبدو سيئًا على الخلفية الداكنة، فيُلغى هناك.
        boxShadow: ColorManager.isDark
            ? null
            : [
                BoxShadow(
                  color: primary.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // دوائر زخرفية خفيفة في الخلفية
          PositionedDirectional(
            top: -34,
            end: -26,
            child: _Bubble(size: 110, alpha: 0.08),
          ),
          PositionedDirectional(
            bottom: -44,
            start: -30,
            child: _Bubble(size: 120, alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "wallet_available_balance".tr,
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  Money.format(wallet.balance),
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.1,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            icon: Icons.lock_outline_rounded,
                            label: "wallet_frozen_balance".tr,
                            value: Money.format(wallet.frozenBalance),
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        Expanded(
                          child: _Stat(
                            icon: Icons.savings_outlined,
                            label: "wallet_total_balance".tr,
                            value: Money.format(wallet.totalBalance),
                          ),
                        ),
                      ],
                    ),
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
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
              : ColorManager.colorWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? ColorManager.colorPrimary
                : ColorManager.colorTextFieldEnabledBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w500,
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
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FontSize.s10_5,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
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

    return TripCardShell(
      onTap: canOpenBooking ? () => onOpenBooking(refId) : null,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: display.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(display.icon, color: display.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display.label,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (ref != null)
                  TripCardChip(
                    icon: Icons.tag,
                    color: ColorManager.colorGrey6,
                    label: refId == null
                        ? WalletTypeDisplay.referenceLabel(ref.type)
                        : "${WalletTypeDisplay.referenceLabel(ref.type)} #$refId",
                  ),
                const SizedBox(height: 4),
                Text(
                  "${DateConverter.dateToStringAR(tx.createdAt)} • ${DateConverter.timeUTCToString(tx.createdAt)}",
                  style: TextStyle(
                    fontSize: FontSize.s10,
                    color: ColorManager.colorGrey6.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppPadding.p8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Money.signed(sign, tx.amount),
                style: TextStyle(
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w500,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "wallet_balance_after".trParams({
                  "amount": Money.format(tx.balanceAfter),
                }),
                style: TextStyle(
                  fontSize: FontSize.s10,
                  color: ColorManager.colorGrey6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
