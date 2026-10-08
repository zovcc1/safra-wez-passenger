import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/guest_gate_widget.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/governorate_model.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/data/models/trip_search_result_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_bottom_sheet.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_search_text_field.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/pages/trips_page/trips_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class TripsPage extends GetView<TripsPageController> {
  const TripsPage({super.key});

  /// المحتوى يمتد خلف شريط التنقل السفلي (extendBody) فنترك مسافة بقدره.
  static const double _bottomNavInset = 48;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.reload,
          child: CustomScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: FadeSlideIn(child: _SearchForm())),
              SliverToBoxAdapter(
                child: Padding(
                  key: controller.resultsAnchorKey,
                  padding: const EdgeInsets.fromLTRB(
                    AppPadding.p16,
                    AppPadding.p8,
                    AppPadding.p16,
                    0,
                  ),
                  child: Obx(() => _resultsHeader()),
                ),
              ),
              Obx(() => _resultsSliver()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultsHeader() {
    final hasData = controller.loadingState.value == LoadingState.doneWithData;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(sizeFactor: animation, child: child),
      ),
      child: !hasData
          ? const SizedBox.shrink(key: ValueKey('header-empty'))
          : Padding(
              key: const ValueKey('header-count'),
              padding: const EdgeInsets.only(
                top: AppPadding.p8,
                bottom: AppPadding.p12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "trips_results_title".tr,
                      style: TextStyle(
                        fontSize: FontSize.s15,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.colorPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "trips_results_count".trParams({
                        "count": "${controller.results.length}",
                      }),
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _resultsSliver() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _bottomNavInset),
          child: FadeSlideIn(
            child: EmptyStateWidget(
              icon: Icons.travel_explore_outlined,
              title: "trips_empty_search_title".tr,
              subtitle: "trips_empty_search_subtitle".tr,
            ),
          ),
        ),
      );
    }

    if (state == LoadingState.loading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _bottomNavInset),
          child: Center(
            child: FadeSlideIn(offset: 8, child: AppLoader(size: 42)),
          ),
        ),
      );
    }

    if (state == LoadingState.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _bottomNavInset),
          child: FadeSlideIn(
            child: ErrorPlaceholderWidget(
              title: "trips_error_results_title".tr,
            ),
          ),
        ),
      );
    }

    if (state == LoadingState.doneWithNoData) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _bottomNavInset),
          child: FadeSlideIn(
            child: EmptyStateWidget(
              icon: Icons.search_off_outlined,
              title: "trips_no_results_title".tr,
              subtitle: "trips_no_results_subtitle".tr,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p16,
        0,
        AppPadding.p16,
        AppPadding.p24 + 64,
      ),
      sliver: SliverList.separated(
        itemCount:
            controller.results.length + (controller.loadingMore.value ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p8),
        itemBuilder: (context, index) {
          if (index >= controller.results.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p16),
              child: Center(child: AppLoader.dots(size: 20)),
            );
          }
          return FadeSlideIn(
            delay: Duration(milliseconds: 40 * index.clamp(0, 8)),
            child: _TripResultCard(result: controller.results[index]),
          );
        },
      ),
    );
  }
}

class _SearchForm extends GetView<TripsPageController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppPadding.p16,
        AppPadding.p12,
        AppPadding.p16,
        AppPadding.p4,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: controller.toggleSearchExpanded,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "trips_search_title".tr,
                    style: TextStyle(
                      fontSize: FontSize.s20,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
                Obx(
                  () => AnimatedRotation(
                    turns: controller.searchExpanded.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: ColorManager.colorGrey6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: controller.searchExpanded.value
                  ? _formBody(context)
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _FieldLabel("trips_origin_label".tr),
        Obx(
          () => _DropdownField(
            icon: Icons.location_on_rounded,
            iconColor: ColorManager.colorPrimary,
            value: controller.originGovernorate.value?.displayName,
            onTap: () => _openGovernoratePicker(
              context,
              title: "trips_origin_governorate_title".tr,
              onSelected: controller.setOriginGovernorate,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _SwapDivider(onSwap: controller.swapGovernorates),
        _FieldLabel("trips_destination_label".tr),
        Obx(
          () => _DropdownField(
            icon: Icons.location_on_rounded,
            iconColor: ColorManager.colorOrange,
            value: controller.destinationGovernorate.value?.displayName,
            onTap: () => _openGovernoratePicker(
              context,
              title: "trips_destination_governorate_title".tr,
              onSelected: controller.setDestinationGovernorate,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => _DateField(
                  label: "trips_date_from_label".tr,
                  date: controller.departureDateFrom.value,
                  onTap: () => controller.pickDepartureDateFrom(context),
                  onClear: controller.departureDateFrom.value == null
                      ? null
                      : controller.clearDepartureDateFrom,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _DateField(
                  label: "trips_date_to_label".tr,
                  date: controller.departureDateTo.value,
                  onTap: () => controller.pickDepartureDateTo(context),
                  onClear: controller.departureDateTo.value == null
                      ? null
                      : controller.clearDepartureDateTo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FieldLabel("trips_passengers_label".tr, bottom: 0),
            ),
            Obx(() => _SeatsStepper(seats: controller.seatsNeeded.value)),
          ],
        ),
        const SizedBox(height: 10),
        _FieldLabel("trips_vehicle_type_label".tr),
        Obx(() => _VehicleTypeChips(selected: controller.vehicleType.value)),
        const SizedBox(height: 14),
        Obx(
          () => AppButton(
            text: "trips_search_button".tr,
            icon: const Icon(Icons.search, color: Colors.white, size: 22),
            radius: 10,
            minHeight: 44,
            loadingMode: controller.loadingState.value == LoadingState.loading,
            onPressed: controller.search,
          ),
        ),
      ],
    );
  }

  void _openGovernoratePicker(
    BuildContext context, {
    required String title,
    required void Function(GovernorateModel?) onSelected,
  }) {
    showCustomBottomSheet(
      title: title,
      height: MediaQuery.of(context).size.height * 0.7,
      content: _GovernoratePickerContent(onSelected: onSelected),
    );
  }
}

class _GovernoratePickerContent extends GetView<TripsPageController> {
  const _GovernoratePickerContent({required this.onSelected});

  final void Function(GovernorateModel?) onSelected;

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final filtered = <GovernorateModel>[].obs;

    return Obx(() {
      final state = controller.governoratesLoadingState.value;

      if (state == LoadingState.loading || state == LoadingState.idle) {
        return const Padding(
          padding: EdgeInsets.all(AppPadding.p24),
          child: AppLoader(),
        );
      }

      if (state == LoadingState.hasError) {
        return Padding(
          padding: const EdgeInsets.all(AppPadding.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("trips_governorates_error".tr),
              const SizedBox(height: AppPadding.p12),
              AppButton(
                text: "common_retry".tr,
                onPressed: controller.retryLoadGovernorates,
              ),
            ],
          ),
        );
      }

      if (filtered.isEmpty && searchController.text.isEmpty) {
        filtered.assignAll(controller.governorates);
      }

      return Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSearchTextField(
              hint: "trips_governorate_search_hint".tr,
              controller: searchController,
              onChanged: (value) {
                final query = value.trim();
                if (query.isEmpty) {
                  filtered.assignAll(controller.governorates);
                } else {
                  filtered.assignAll(
                    controller.governorates.where(
                      (g) => g.displayName.contains(query),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppPadding.p12),
            Flexible(
              child: Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final governorate = filtered[index];
                    return ListTile(
                      title: Text(governorate.displayName),
                      onTap: () {
                        onSelected(governorate);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// يضيف حركة "ضغط" خفيفة (scale down) فوق أي عنصر تفاعلي دون التأثير على
/// معالج الضغط الأصلي (InkWell) الخاص به.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.bottom = 6});

  final String text;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text(
        text,
        style: TextStyle(
          fontSize: FontSize.s13,
          fontWeight: FontWeight.w500,
          color: ColorManager.colorDoveGray600,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
          decoration: BoxDecoration(
            color: ColorManager.colorWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorManager.colorTextFieldEnabledBorder),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Align(
                    key: ValueKey(value),
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      value ?? "trips_choose_governorate".tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: FontSize.s15,
                        fontWeight: FontWeight.w500,
                        color: value == null
                            ? ColorManager.colorDoveGray300
                            : ColorManager.colorFontPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 22,
                color: ColorManager.colorGrey6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwapDivider extends StatefulWidget {
  const _SwapDivider({required this.onSwap});

  final VoidCallback onSwap;

  @override
  State<_SwapDivider> createState() => _SwapDividerState();
}

class _SwapDividerState extends State<_SwapDivider> {
  int _turns = 0;

  @override
  Widget build(BuildContext context) {
    // نفس فاصل الكاردات المتلاشي، لكن يخفت باتجاه الأطراف ويشتد قرب الزر.
    final edge = ColorManager.colorTextFieldEnabledBorder;
    Widget line({required bool fadeAtStart}) => Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: fadeAtStart
                ? [edge.withValues(alpha: 0), edge.withValues(alpha: 0.9)]
                : [edge.withValues(alpha: 0.9), edge.withValues(alpha: 0)],
          ),
        ),
      ),
    );
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          line(fadeAtStart: true),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() => _turns++);
              widget.onSwap();
            },
            customBorder: const CircleBorder(),
            child: AnimatedRotation(
              turns: _turns * 0.5,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: ColorManager.colorWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorManager.colorTextFieldEnabledBorder,
                  ),
                ),
                child: Icon(
                  Icons.swap_vert_rounded,
                  size: 20,
                  color: ColorManager.colorPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          line(fadeAtStart: false),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        _PressScale(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
              decoration: BoxDecoration(
                color: ColorManager.colorWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: date == null
                      ? ColorManager.colorTextFieldEnabledBorder
                      : ColorManager.colorPrimary.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: ColorManager.colorDoveGray600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        date == null
                            ? "trips_any_date".tr
                            : DateConverter.dateUTCToString(date),
                        key: ValueKey(date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w500,
                          color: date == null
                              ? ColorManager.colorDoveGray300
                              : ColorManager.colorFontPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (onClear != null)
                    InkWell(
                      onTap: onClear,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: ColorManager.colorGrey6,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeatsStepper extends GetView<TripsPageController> {
  const _SeatsStepper({required this.seats});

  final int? seats;

  @override
  Widget build(BuildContext context) {
    final value = seats ?? 1;
    final active = seats != null;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorManager.colorPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(
            icon: Icons.remove,
            onTap: active
                ? () => controller.setSeatsNeeded(value > 1 ? value - 1 : null)
                : null,
          ),
          SizedBox(
            width: 52,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  "$value",
                  key: ValueKey(value),
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ),
            ),
          ),
          _stepButton(
            icon: Icons.add,
            onTap: () => controller.setSeatsNeeded(value + 1),
          ),
        ],
      ),
    );
  }

  Widget _stepButton({required IconData icon, required VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? ColorManager.colorWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? ColorManager.colorPrimary
              : ColorManager.colorDoveGray300,
        ),
      ),
    );
  }
}

class _VehicleTypeChips extends GetView<TripsPageController> {
  const _VehicleTypeChips({required this.selected});

  final String? selected;

  static IconData _iconFor(String? slug) => switch (slug) {
    'car' => Icons.directions_car_rounded,
    'van' => Icons.airport_shuttle_rounded,
    'bus' => Icons.directions_bus_rounded,
    _ => Icons.apps_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final options = TripsPageController.vehicleTypeOptions;
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _chip(options[i])),
        ],
      ],
    );
  }

  Widget _chip(VehicleTypeOption option) {
    final isSelected = option.slug == selected;
    final color = isSelected
        ? ColorManager.colorPrimary
        : ColorManager.colorFontPrimary;
    return _PressScale(
      child: GestureDetector(
        onTap: () => controller.setVehicleType(option.slug),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorManager.colorPrimary.withValues(alpha: 0.06)
                : ColorManager.colorWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? ColorManager.colorPrimary
                  : ColorManager.colorTextFieldEnabledBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(option.slug), size: 20, color: color),
              const SizedBox(height: 3),
              Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ratings_count المنشور لا الفعلي. rating_is_default=true → مزوّد جديد بدل النجوم.
class _ProviderRatingPill extends StatelessWidget {
  const _ProviderRatingPill({required this.result});

  final TripSearchResultModel result;

  @override
  Widget build(BuildContext context) {
    if (result.ratingIsDefault) {
      return TripCardChip(
        icon: Icons.fiber_new_rounded,
        color: ColorManager.colorGreen3,
        label: "trips_new_provider".tr,
      );
    }
    return TripCardChip(
      icon: Icons.star_rounded,
      color: ColorManager.colorOrange,
      label: "trips_provider_rating".trParams({
        "rating": result.avgRating.toStringAsFixed(1),
        "count": "${result.ratingsCount}",
      }),
    );
  }
}

class _TripResultCard extends StatelessWidget {
  const _TripResultCard({required this.result});

  final TripSearchResultModel result;

  @override
  Widget build(BuildContext context) {
    final badgeColor = result.isOpenTrip
        ? ColorManager.colorOrange
        : ColorManager.colorPrimary;
    final eventTime = result.isOpenTrip
        ? result.expiresAt
        : result.departureTime;
    final dateText = eventTime == null
        ? "booking_details_no_date".tr
        : "${result.isOpenTrip ? "${"booking_details_expires".tr} " : ""}"
              "${DateFormat("EEEE d MMMM", "ar").format(eventTime)}";
    final showPickupChip =
        !result.isOpenTrip && result.pickupMode != PickupMode.fixedPoint;

    return CompactTripCard(
      onTap: () => _onTapResult(result),
      title: result.route.displayName,
      badge: result.isOpenTrip
          ? "trips_open_trip_badge".tr
          : "trips_scheduled_trip_badge".tr,
      badgeColor: badgeColor,
      details: [
        TextSpan(text: "$dateText · "),
        CompactTripCard.strong(DateConverter.timeUTCToString(eventTime)),
        TextSpan(
          text:
              " · ${"trips_seats_available_short".trParams({"seats": "${result.availableSeats}"})}",
        ),
      ],
      price: Money.format(result.basePrice),
      extra: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          TripCardChip(
            icon: Icons.directions_car_outlined,
            color: ColorManager.colorGrey6,
            label: result.vehicle.vehicleType,
          ),
          if (showPickupChip)
            TripCardChip(
              icon: result.pickupMode == PickupMode.doorToDoor
                  ? Icons.home_outlined
                  : Icons.location_on_outlined,
              color: ColorManager.colorPrimary,
              label: result.pickupMode == PickupMode.doorToDoor
                  ? "pickup_mode_door_to_door".tr
                  : "pickup_mode_collection_points".trParams({
                      "count": "${result.collectionPoints.length}",
                    }),
            ),
          _ProviderRatingPill(result: result),
        ],
      ),
    );
  }

  void _onTapResult(TripSearchResultModel result) {
    if (!Get.find<CacheService>().isLoggedIn()) {
      GuestGateWidget.promptLogin();
      return;
    }
    Get.toNamed(AppRoutes.createBookingRoute, arguments: result);
  }
}
