import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safraa_passenger_app/core/services/places_search_service.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/pickup_picker_page/pickup_picker_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

/// ستايل خريطة داكن ليتناسق مع الوضع الداكن (بدل الخريطة الفاتحة).
const String _kDarkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d2330"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#9aa4b5"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d2330"}]},
  {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#3a4358"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#8b95a8"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1f3a33"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c3547"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1d2330"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3b4660"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#262e3f"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0f1520"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#5d6a82"}]}
]
''';

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
                      style: ColorManager.isDark && type == MapType.normal
                          ? _kDarkMapStyle
                          : null,
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
                  Positioned.fill(
                    child: Obx(() {
                      final focused = controller.searchExpanded;
                      final bar = _SearchBar(
                        key: controller.searchBarKey,
                        controller: controller,
                        expanded: focused,
                      );
                      if (!focused) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.all(AppSize.s12),
                            child: bar,
                          ),
                        );
                      }
                      return Container(
                        color: ColorManager.colorBackground,
                        padding: EdgeInsets.all(AppSize.s12),
                        child: bar,
                      );
                    }),
                  ),
                ],
              ),
            ),
            Obx(
              () => controller.searchExpanded
                  ? const SizedBox.shrink()
                  : _BottomPanel(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.controller});

  final PickupPickerPageController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                      _SelectedPlace(controller: controller),
                      SizedBox(height: AppSize.s12),
                      CustomTextField(
                        title: "pickup_picker_note_title".tr,
                        hint: "pickup_picker_address_hint".tr,
                        textEditingController: controller.addressController,
                        textInputType: TextInputType.streetAddress,
                        fillColor: ColorManager.colorBackground,
                        borderRadius: 14,
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
    );
  }
}

/// اسم المكان المختار بخط كبير أعلى اللوحة، تحته المنطقة وحالة الخدمة.
class _SelectedPlace extends StatelessWidget {
  const _SelectedPlace({required this.controller});

  final PickupPickerPageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final title = controller.placeTitle.value;
      final region = controller.placeRegion.value;
      final inService = controller.inServiceArea;
      final statusColor = inService == true
          ? ColorManager.colorGreen3
          : ColorManager.colorError300;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty ? "pickup_place_unknown".tr : title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: FontSize.s20,
              fontWeight: FontWeight.w600,
              color: ColorManager.colorFontPrimary,
            ),
          ),
          const SizedBox(height: 4),
          if (region.isNotEmpty)
            Text(
              region,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: FontSize.s13,
                height: 1.4,
                color: ColorManager.colorGrey6,
              ),
            ),
          if (inService != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  inService
                      ? "pickup_service_inside".tr
                      : "pickup_service_outside".tr,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color, required this.fillColor});

  final Color color;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.6;
    const dashes = 28;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - strokeWidth;
    canvas.drawCircle(center, radius, Paint()..color = fillColor);
    final stroke = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const sweep = 2 * 3.141592653589793 / dashes;
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, stroke);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) =>
      old.color != color || old.fillColor != fillColor;
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    const double size = 30;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // دائرة حول رأس الدبوس تتحرك معه (حجمها ثابت بالبكسل).
        CustomPaint(
          size: const Size(72, 72),
          painter: _DashedCirclePainter(
            color: ColorManager.colorPrimary,
            fillColor: ColorManager.colorPrimary.withValues(alpha: 0.12),
          ),
        ),
        Container(
          width: 6,
          height: 3,
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
  const _SearchBar({
    super.key,
    required this.controller,
    this.expanded = false,
  });

  final PickupPickerPageController controller;

  /// أثناء البحث تملأ القائمة الشاشة بدل أن تطفو فوق الخريطة.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
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
                          child: AppLoader.dots(size: 14),
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
          // تظهر القائمة عند التركيز (فيها "استخدم موقعي الحالي") أو عند وجود نتائج.
          final focused = controller.searchFocused.value;
          if (!focused && results.isEmpty && !empty) {
            return const SizedBox.shrink();
          }

          final list = ListView(
            shrinkWrap: !expanded,
            padding: EdgeInsets.zero,
            children: [
              if (focused) ...[
                ListTile(
                  leading: Icon(
                    Icons.my_location_rounded,
                    color: ColorManager.colorPrimary,
                  ),
                  title: Text(
                    "pickup_use_my_location".tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorManager.colorPrimary,
                    ),
                  ),
                  onTap: controller.useMyLocationFromSearch,
                ),
                Divider(height: 1, color: ColorManager.colorDivider),
              ],
              if (empty)
                Padding(
                  padding: EdgeInsets.all(AppSize.s14),
                  child: Text(
                    "pickup_no_results".tr,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: ColorManager.colorDoveGray600,
                    ),
                  ),
                ),
              for (var i = 0; i < results.length; i++) ...[
                if (i > 0) Divider(height: 1, color: ColorManager.colorDivider),
                _ResultTile(
                  result: results[i],
                  onTap: () => controller.selectResult(results[i]),
                ),
              ],
            ],
          );

          // Material (لا Container ملوّن) كي تظهر خلفية/تموّج الـ ListTile.
          final card = Material(
            elevation: 4,
            color: ColorManager.colorWhite,
            borderRadius: BorderRadius.circular(AppSize.s14),
            clipBehavior: Clip.antiAlias,
            child: list,
          );
          if (expanded) {
            return Flexible(
              child: Padding(
                padding: EdgeInsets.only(top: AppSize.s6),
                child: Align(alignment: Alignment.topCenter, child: card),
              ),
            );
          }
          return Container(
            margin: EdgeInsets.only(top: AppSize.s6),
            constraints: BoxConstraints(maxHeight: AppSize.sHeight * 0.3),
            child: card,
          );
        }),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.onTap});

  final PlaceSuggestion result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // السطر الثاني لا يكرر الأول (مثل "رجوب / رجوب").
    final subtitle = result.subtitle.trim();
    final showSubtitle = subtitle.isNotEmpty && subtitle != result.title.trim();
    return ListTile(
      dense: true,
      leading: Icon(Icons.place_outlined, color: ColorManager.colorPrimary),
      title: Text(
        result.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: showSubtitle
          ? Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.bodySmall?.copyWith(
                color: ColorManager.colorDoveGray600,
              ),
            )
          : null,
      onTap: onTap,
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
                child: AppLoader.dots(size: 14),
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
