import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:safraa_passenger_app/presentation/custom_widgets/info_pill.dart';
import 'package:safraa_passenger_app/presentation/pages/trips_page/trips_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class TripsPage extends GetView<TripsPageController> {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
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
              padding: const EdgeInsets.only(bottom: AppPadding.p8),
              child: Text(
                "trips_results_count".trParams({
                  "count": "${controller.results.length}",
                }),
                style: TextStyle(
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.colorDoveGray600,
                ),
              ),
            ),
    );
  }

  Widget _resultsSliver() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: FadeSlideIn(
          child: EmptyStateWidget(
            icon: Icons.travel_explore_outlined,
            title: "trips_empty_search_title".tr,
            subtitle: "trips_empty_search_subtitle".tr,
          ),
        ),
      );
    }

    if (state == LoadingState.loading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: FadeSlideIn(offset: 8, child: AppLoader(size: 42)),
        ),
      );
    }

    if (state == LoadingState.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: FadeSlideIn(
          child: ErrorPlaceholderWidget(title: "trips_error_results_title".tr),
        ),
      );
    }

    if (state == LoadingState.doneWithNoData) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: FadeSlideIn(
          child: EmptyStateWidget(
            icon: Icons.search_off_outlined,
            title: "trips_no_results_title".tr,
            subtitle: "trips_no_results_subtitle".tr,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p16,
        0,
        AppPadding.p16,
        AppPadding.p24,
      ),
      sliver: SliverList.separated(
        itemCount:
            controller.results.length + (controller.loadingMore.value ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: controller.toggleSearchExpanded,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(
                  Icons.route_outlined,
                  size: AppSize.s20,
                  color: ColorManager.colorPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "trips_search_title".tr,
                    style: TextStyle(
                      fontSize: FontSize.s15,
                      fontWeight: FontWeight.bold,
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
        const SizedBox(height: AppPadding.p10),
        Obx(
          () => _RouteSelector(
            origin: controller.originGovernorate.value,
            destination: controller.destinationGovernorate.value,
            onTapOrigin: () => _openGovernoratePicker(
              context,
              title: "trips_origin_governorate_title".tr,
              onSelected: controller.setOriginGovernorate,
            ),
            onTapDestination: () => _openGovernoratePicker(
              context,
              title: "trips_destination_governorate_title".tr,
              onSelected: controller.setDestinationGovernorate,
            ),
            onSwap: controller.swapGovernorates,
          ),
        ),
        const SizedBox(height: AppPadding.p8),
        Row(
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
            const SizedBox(width: AppPadding.p8),
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
        const SizedBox(height: AppPadding.p8),
        Row(
          children: [
            Obx(() => _SeatsStepper(seats: controller.seatsNeeded.value)),
            const SizedBox(width: AppPadding.p8),
            Expanded(
              child: Obx(
                () => _VehicleTypeChips(selected: controller.vehicleType.value),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppPadding.p10),
        Obx(
          () => AppButton(
            text: "trips_search_button".tr,
            icon: const Icon(Icons.search, color: Colors.white, size: 18),
            radius: 12,
            minHeight: 42,
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

class _RouteSelector extends StatelessWidget {
  const _RouteSelector({
    required this.origin,
    required this.destination,
    required this.onTapOrigin,
    required this.onTapDestination,
    required this.onSwap,
  });

  final GovernorateModel? origin;
  final GovernorateModel? destination;
  final VoidCallback onTapOrigin;
  final VoidCallback onTapDestination;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorManager.colorTextFieldEnabledBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _RouteRow(
                  label: "trips_route_from_label".tr,
                  value: origin?.displayName,
                  dotColor: ColorManager.colorPrimary,
                  onTap: onTapOrigin,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 32),
                  child: Divider(
                    height: 1,
                    color: ColorManager.colorTextFieldEnabledBorder,
                  ),
                ),
                _RouteRow(
                  label: "trips_route_to_label".tr,
                  value: destination?.displayName,
                  dotColor: ColorManager.colorOrange,
                  onTap: onTapDestination,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
            child: _SwapButton(onSwap: onSwap),
          ),
        ],
      ),
    );
  }
}

class _SwapButton extends StatefulWidget {
  const _SwapButton({required this.onSwap});

  final VoidCallback onSwap;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton> {
  int _turns = 0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() => _turns++);
        widget.onSwap();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedRotation(
        turns: _turns * 0.5,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: ColorManager.colorBackground,
            shape: BoxShape.circle,
            border: Border.all(color: ColorManager.colorTextFieldEnabledBorder),
          ),
          child: Icon(
            Icons.swap_vert_rounded,
            size: 18,
            color: ColorManager.colorPrimary,
          ),
        ),
      ),
    );
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

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.label,
    required this.value,
    required this.dotColor,
    required this.onTap,
  });

  final String label;
  final String? value;
  final Color dotColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12,
            vertical: 6,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: value == null
                      ? []
                      : [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.colorGrey6,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    value ?? "trips_choose_governorate".tr,
                    key: ValueKey(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: FontSize.s14,
                      fontWeight: FontWeight.w600,
                      color: value == null
                          ? ColorManager.colorDoveGray300
                          : ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: ColorManager.colorGrey6,
              ),
            ],
          ),
        ),
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
    return _PressScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12,
            vertical: 6,
          ),
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
                size: AppSize.s16,
                color: ColorManager.colorDoveGray600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: FontSize.s11,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        date == null
                            ? "trips_any_date".tr
                            : DateConverter.dateUTCToString(date),
                        key: ValueKey(date),
                        style: TextStyle(
                          fontSize: FontSize.s13,
                          fontWeight: FontWeight.w600,
                          color: date == null
                              ? ColorManager.colorDoveGray300
                              : ColorManager.colorFontPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: ColorManager.colorGrey6,
                  ),
                ),
            ],
          ),
        ),
      ),
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
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground,
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
            width: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.airline_seat_recline_normal_rounded,
                  size: 14,
                  color: active
                      ? ColorManager.colorPrimary
                      : ColorManager.colorDoveGray300,
                ),
                const SizedBox(width: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    "$value",
                    key: ValueKey(value),
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.bold,
                      color: active
                          ? ColorManager.colorPrimary
                          : ColorManager.colorGrey6,
                    ),
                  ),
                ),
              ],
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
        width: 30,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? ColorManager.colorWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? ColorManager.colorFontPrimary
              : ColorManager.colorDoveGray300,
        ),
      ),
    );
  }
}

class _VehicleTypeChips extends GetView<TripsPageController> {
  const _VehicleTypeChips({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context) {
    final options = TripsPageController.vehicleTypeOptions;
    final selectedIndex = options
        .indexWhere((o) => o.slug == selected)
        .clamp(0, options.length - 1);
    final x = options.length == 1
        ? 0.0
        : -1 + 2 * selectedIndex / (options.length - 1);

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: AlignmentDirectional(x, 0),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 1 / options.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorManager.colorWhite,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final option in options)
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setVehicleType(option.slug),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: FontSize.s12,
                          fontWeight: option.slug == selected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: option.slug == selected
                              ? ColorManager.colorPrimary
                              : ColorManager.colorGrey6,
                        ),
                        child: Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
      return InfoPill(
        icon: Icons.fiber_new_rounded,
        color: ColorManager.colorGreen3,
        text: "trips_new_provider".tr,
      );
    }
    return InfoPill(
      icon: Icons.star_rounded,
      color: ColorManager.colorOrange,
      text: "trips_provider_rating".trParams({
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
    final priceLabel = Money.format(result.basePrice);
    final badgeColor = result.isOpenTrip
        ? ColorManager.colorOrange
        : ColorManager.colorPrimary;
    final timeText = result.isOpenTrip
        ? "trips_expires_at".trParams({
            "date": DateConverter.dateToStringAR(result.expiresAt),
            "time": DateConverter.timeUTCToString(result.expiresAt),
          })
        : "trips_departure_at".trParams({
            "date": DateConverter.dateToStringAR(result.departureTime),
            "time": DateConverter.timeUTCToString(result.departureTime),
          });

    return Material(
      color: ColorManager.colorWhite,
      borderRadius: BorderRadius.circular(AppSize.s16),
      elevation: 0,
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
          onTap: () => _onTapResult(result),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: AppPadding.p10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: AppSize.s20,
                      color: ColorManager.colorPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.route.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: FontSize.s15,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result.isOpenTrip
                            ? "trips_open_trip_badge".tr
                            : "trips_scheduled_trip_badge".tr,
                        style: TextStyle(
                          fontSize: FontSize.s10_5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.p8),
                Wrap(
                  spacing: AppPadding.p8,
                  runSpacing: AppPadding.p8,
                  children: [
                    InfoPill(
                      icon: Icons.directions_car_outlined,
                      text: "trips_result_seats_available".trParams({
                        "vehicleType": result.vehicle.vehicleType,
                        "seats": "${result.availableSeats}",
                      }),
                    ),
                    InfoPill(
                      icon: result.isOpenTrip
                          ? Icons.hourglass_bottom_outlined
                          : Icons.schedule_outlined,
                      text: timeText,
                    ),
                    if (!result.isOpenTrip &&
                        result.pickupMode != PickupMode.fixedPoint)
                      InfoPill(
                        icon: result.pickupMode == PickupMode.doorToDoor
                            ? Icons.home_outlined
                            : Icons.pin_drop_outlined,
                        color: ColorManager.colorPrimary,
                        text: result.pickupMode == PickupMode.doorToDoor
                            ? "pickup_mode_door_to_door".tr
                            : "pickup_mode_collection_points".trParams({
                                "count": "${result.collectionPoints.length}",
                              }),
                      ),
                    _ProviderRatingPill(result: result),
                  ],
                ),
                const SizedBox(height: AppPadding.p8),
                Divider(
                  height: 1,
                  color: ColorManager.colorTextFieldEnabledBorder,
                ),
                const SizedBox(height: AppPadding.p8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        priceLabel,
                        style: TextStyle(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.colorPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: ColorManager.colorGrey6,
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

  void _onTapResult(TripSearchResultModel result) {
    if (!Get.find<CacheService>().isLoggedIn()) {
      GuestGateWidget.promptLogin();
      return;
    }
    Get.toNamed(AppRoutes.createBookingRoute, arguments: result);
  }
}
