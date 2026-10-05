import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/pickup_picker_page/pickup_picker_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class PickupPickerPage extends GetView<PickupPickerPageController> {
  const PickupPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: ColorManager.colorBackground,
        appBar: NormalAppBar(title: "pickup_picker_title".tr, backIcon: true),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Obx(() {
                    // قراءة صريحة للمراقَبات كي لا يرمي Obx خطأ "improper use".
                    final type = controller.mapType.value;
                    return GoogleMap(
                      mapType: type,
                      initialCameraPosition: CameraPosition(
                        target: controller.initialTarget,
                        zoom: 13,
                      ),
                      onMapCreated: (c) => controller.mapController = c,
                      onCameraMove: controller.onCameraMove,
                      onCameraIdle: controller.onCameraIdle,
                      onCameraMoveStarted: controller.onCameraMoveStarted,
                      onTap: controller.onTap,
                      circles: controller.circles,
                      markers: controller.markers,
                      polylines: controller.polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    );
                  }),
                  const IgnorePointer(child: Center(child: _CenterPin())),
                  PositionedDirectional(
                    top: AppSize.s12,
                    start: AppSize.s12,
                    end: AppSize.s12,
                    child: _SearchBar(controller: controller),
                  ),
                  PositionedDirectional(
                    top: AppSize.s12 + 56,
                    start: AppPadding.p12,
                    end: AppPadding.p12,
                    child: Obx(() {
                      final route = controller.currentRoute;
                      if (route == null) return const SizedBox.shrink();
                      final km = (route.distanceMeters / 1000).toStringAsFixed(
                        1,
                      );
                      final min = (route.durationSeconds / 60).round();
                      return Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.colorWhite,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "pickup_route_summary".trParams({
                                  "km": km,
                                  "min": "$min",
                                }),
                                style: TextStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.colorFontPrimary,
                                ),
                              ),
                              if (controller.routes.length > 1)
                                Text(
                                  "pickup_route_switch_hint".tr,
                                  style: TextStyle(
                                    fontSize: FontSize.s11,
                                    color: ColorManager.colorGrey6,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  PositionedDirectional(
                    end: AppSize.s12,
                    bottom: AppSize.s16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MapTypeButton(controller: controller),
                        SizedBox(height: AppSize.s8),
                        _MapControlCard(
                          children: [
                            _MapIconButton(
                              icon: Icons.add_rounded,
                              onPressed: () => controller.zoomBy(1),
                            ),
                            Divider(
                              height: 1,
                              indent: 8,
                              endIndent: 8,
                              color: ColorManager.colorDivider,
                            ),
                            _MapIconButton(
                              icon: Icons.remove_rounded,
                              onPressed: () => controller.zoomBy(-1),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSize.s8),
                        Obx(
                          () => _MapControlCard(
                            children: [
                              _MapIconButton(
                                icon: Icons.my_location_rounded,
                                loading: controller.locating.value,
                                onPressed: controller.useMyLocation,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: ColorManager.colorWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(AppSize.sWidth * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 16,
                            color: ColorManager.colorDoveGray600,
                          ),
                          SizedBox(width: AppSize.s6),
                          Expanded(
                            child: Text(
                              "pickup_picker_hint".tr,
                              style: Get.textTheme.labelSmall?.copyWith(
                                color: ColorManager.colorDoveGray600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize.s12),
                      CustomTextField(
                        title: "pickup_picker_address_hint".tr,
                        hint: "pickup_picker_address_hint".tr,
                        textEditingController: controller.addressController,
                        textInputType: TextInputType.streetAddress,
                        fillColor: ColorManager.colorBackground,
                        borderRadius: 14,
                        onChanged: controller.onAddressEdited,
                      ),
                      SizedBox(height: AppSize.s14),
                      AppButton(
                        text: "pickup_picker_confirm".tr,
                        radius: 14,
                        minHeight: 54,
                        onPressed: controller.confirm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    const double size = 44;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 10,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -size / 2),
          child: Icon(
            Icons.location_on_rounded,
            size: size,
            color: ColorManager.colorPrimary,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final PickupPickerPageController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(AppSize.s14),
          color: ColorManager.colorWhite,
          child: TextField(
            controller: controller.searchController,
            focusNode: controller.searchFocus,
            textInputAction: TextInputAction.search,
            onChanged: controller.onSearchChanged,
            onSubmitted: (_) => controller.search(),
            decoration: InputDecoration(
              hintText: "pickup_search_hint".tr,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSize.s14,
                vertical: AppSize.s14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: ColorManager.colorDoveGray600,
              ),
              suffixIcon: Obx(
                () => controller.searching.value
                    ? Padding(
                        padding: EdgeInsets.all(AppSize.s12),
                        child: SizedBox(
                          width: AppSize.s18,
                          height: AppSize.s18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorManager.colorPrimary,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
        ),
        Obx(() {
          final results = controller.searchResults;
          final empty =
              controller.searchedOnce.value &&
              !controller.searching.value &&
              results.isEmpty;
          if (results.isEmpty && !empty) return const SizedBox.shrink();

          return Container(
            margin: EdgeInsets.only(top: AppSize.s6),
            constraints: BoxConstraints(maxHeight: AppSize.sHeight * 0.3),
            decoration: BoxDecoration(
              color: ColorManager.colorWhite,
              borderRadius: BorderRadius.circular(AppSize.s14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                ),
              ],
            ),
            child: empty
                ? Padding(
                    padding: EdgeInsets.all(AppSize.s14),
                    child: Text(
                      "pickup_no_results".tr,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: ColorManager.colorDoveGray600,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: ColorManager.colorDivider),
                    itemBuilder: (context, index) => ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.place_outlined,
                        color: ColorManager.colorPrimary,
                      ),
                      title: Text(
                        results[index].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: results[index].subtitle.isEmpty
                          ? null
                          : Text(
                              results[index].subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Get.textTheme.bodySmall?.copyWith(
                                color: ColorManager.colorDoveGray600,
                              ),
                            ),
                      onTap: () => controller.selectResult(results[index]),
                    ),
                  ),
          );
        }),
      ],
    );
  }
}

class _MapControlCard extends StatelessWidget {
  const _MapControlCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(AppSize.s12),
        border: Border.all(color: ColorManager.colorDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSize.s12),
      onTap: onPressed,
      child: SizedBox(
        width: 40,
        height: 40,
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(11),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorManager.colorPrimary,
                ),
              )
            : Icon(icon, size: 22, color: ColorManager.colorPrimary),
      ),
    );
  }
}

class _MapTypeButton extends StatelessWidget {
  const _MapTypeButton({required this.controller});

  final PickupPickerPageController controller;

  @override
  Widget build(BuildContext context) {
    final options = <MapType, String>{
      MapType.normal: "pickup_map_normal".tr,
      MapType.satellite: "pickup_map_satellite".tr,
      MapType.hybrid: "pickup_map_hybrid".tr,
      MapType.terrain: "pickup_map_terrain".tr,
    };
    return PopupMenuButton<MapType>(
      tooltip: "pickup_map_type".tr,
      onSelected: (type) => controller.mapType.value = type,
      itemBuilder: (_) => [
        for (final e in options.entries)
          PopupMenuItem(
            value: e.key,
            child: Obx(
              () => Row(
                children: [
                  Icon(
                    controller.mapType.value == e.key
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 18,
                    color: ColorManager.colorPrimary,
                  ),
                  SizedBox(width: AppSize.s8),
                  Text(e.value),
                ],
              ),
            ),
          ),
      ],
      child: _MapControlCard(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.layers_rounded,
              size: 22,
              color: ColorManager.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
