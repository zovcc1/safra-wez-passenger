import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safraa_passenger_app/core/services/directions_service.dart';
import 'package:safraa_passenger_app/core/services/places_search_service.dart';
import 'package:safraa_passenger_app/data/dto/pickup_dto.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';

/// نصف قطر القبول الافتراضي (pickup_city_radius_km / pickup_corridor_width_km).
/// لا يرجع من أي endpoint، وهما إعدادان يضبطهما الأدمن وقد يتغيران — للرسم
/// فقط. الخادم هو الحَكَم دائمًا.
const double kPickupCityRadiusKm = 10;

/// نتيجة هذه الشاشة: [PickupDto] أو null عند الإلغاء.
class PickupPickerPageController extends GetxController {
  late final GeoPointModel? startPoint;
  late final GeoPointModel? endPoint;
  late final bool allowRoutePickup;

  GoogleMapController? mapController;
  final center = Rxn<LatLng>();
  final locating = false.obs;
  final addressController = TextEditingController();
  final searchController = TextEditingController();
  final searchFocus = FocusNode();

  final searching = false.obs;
  final searchResults = <PlaceSuggestion>[].obs;
  final searchedOnce = false.obs;

  /// البحث نشط (حقل البحث عليه التركيز): تتحول الشاشة لقائمة كاملة.
  final searchFocused = false.obs;

  /// القائمة بحجم الصفحة فقط عندما يوجد ما يُعرض (نتائج أو "لا نتائج"): قائمة
  /// فارغة لا تغطي الخريطة.
  bool get searchExpanded =>
      searchFocused.value && (searchResults.isNotEmpty || searchedOnce.value);

  /// يحفظ حالة حقل البحث عند تبديل الشاشة بين الوضع المصغّر والموسّع.
  final searchBarKey = GlobalKey();
  final mapType = MapType.normal.obs;

  final PlacesSearchService _places = PlacesSearchService();
  Timer? _searchDebounce;
  Timer? _reverseDebounce;
  int _searchSeq = 0;

  /// المكان المختار (من الخريطة أو البحث): الاسم ثم المنطقة. أما
  /// [addressController] فصار ملاحظة يكتبها الراكب للسائق.
  final placeTitle = "".obs;
  final placeRegion = "".obs;

  String get _lang => Get.locale?.languageCode ?? "ar";

  // مسارات الطرق بين البداية والنهاية (عند allow_route_pickup).
  final routes = <RouteOption>[].obs;
  final selectedRoute = 0.obs;
  late final LatLng _initialTarget;

  LatLng? _gpsPoint;

  static const LatLng _fallbackCenter = LatLng(33.5138, 36.2765); // دمشق

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? const {};
    startPoint = args["startPoint"] as GeoPointModel?;
    endPoint = args["endPoint"] as GeoPointModel?;
    allowRoutePickup = args["allowRoutePickup"] == true;
    final initial = args["initial"] as BookingPickupModel?;
    if (initial != null && initial.hasCoordinates) {
      center.value = LatLng(initial.latitude!, initial.longitude!);
      placeTitle.value = initial.address ?? "";
    } else if (startPoint != null) {
      center.value = LatLng(startPoint!.latitude, startPoint!.longitude);
    } else {
      center.value = _fallbackCenter;
    }
    _initialTarget = center.value!;
    searchFocus.addListener(() => searchFocused.value = searchFocus.hasFocus);
    _loadRoutes();
  }

  LatLng get initialTarget => _initialTarget;

  Future<void> _loadRoutes() async {
    if (!allowRoutePickup || startPoint == null || endPoint == null) return;
    final found = await DirectionsService.fetch(
      LatLng(startPoint!.latitude, startPoint!.longitude),
      LatLng(endPoint!.latitude, endPoint!.longitude),
    );
    if (found.isEmpty) return;
    routes.assignAll(found);
    // المسار الافتراضي: الأقرب (الأقصر مسافة).
    var best = 0;
    for (var i = 1; i < found.length; i++) {
      if (found[i].distanceMeters < found[best].distanceMeters) best = i;
    }
    selectedRoute.value = best;
  }

  void selectRoute(int index) => selectedRoute.value = index;

  RouteOption? get currentRoute =>
      routes.isEmpty ? null : routes[selectedRoute.value];

  void onCameraMove(CameraPosition position) => center.value = position.target;

  void onCameraMoveStarted() => searchFocus.unfocus();

  /// عند توقف الكاميرا نحدّث اسم المكان ومنطقته.
  void onCameraIdle() {
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(const Duration(milliseconds: 600), () async {
      final point = center.value;
      if (point == null) return;
      final place = await _places.reverse(point, language: _lang);
      if (place == null) return;
      placeTitle.value = place.title;
      placeRegion.value = place.region;
    });
  }

  /// داخل منطقة الخدمة؟ null عندما لا توجد نقطة بداية للمقارنة.
  bool? get inServiceArea {
    final point = center.value; // قراءة مراقَبة كي يعيد Obx البناء.
    final start = startPoint;
    if (point == null || start == null) return null;
    return _meters(LatLng(start.latitude, start.longitude), point) <=
        kPickupCityRadiusKm * 1000;
  }

  /// نقر على الخريطة ينقل الدبوس إلى تلك النقطة.
  Future<void> onTap(LatLng position) async {
    searchFocus.unfocus();
    await mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  // ----------------------------------------------------------------- search

  void onSearchChanged(String text) {
    _searchDebounce?.cancel();
    if (text.trim().length < 2) {
      _searchSeq++;
      searchResults.clear();
      searchedOnce.value = false;
      searching.value = false;
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 400), search);
  }

  Future<void> search() async {
    final query = searchController.text.trim();
    if (query.length < 2) return;
    final seq = ++_searchSeq;
    searching.value = true;
    final results = await _places.search(
      query,
      bias: center.value ?? _initialTarget,
      language: _lang,
    );
    if (seq != _searchSeq) return; // نتيجة قديمة تجاوزها بحث أحدث.
    searchedOnce.value = true;
    searchResults.assignAll(results);
    searching.value = false;
  }

  Future<void> selectResult(PlaceSuggestion result) async {
    searchFocus.unfocus();
    _searchSeq++;
    searching.value = false;
    searchResults.clear();
    searchedOnce.value = false;
    searchController.text = result.fullLabel;
    placeTitle.value = result.title;
    placeRegion.value = result.subtitle;
    center.value = result.position;
    await mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(result.position, 17),
    );
  }

  /// أول خيار دائم في البحث: أسرع طريق لمعظم المسافرين.
  Future<void> useMyLocationFromSearch() async {
    searchFocus.unfocus();
    clearSearch();
    await useMyLocation();
  }

  void clearSearch() {
    _searchSeq++;
    searchController.clear();
    searching.value = false;
    searchResults.clear();
    searchedOnce.value = false;
  }

  Set<Circle> get circles {
    final start = startPoint;
    if (start == null) return {};
    return {
      Circle(
        circleId: const CircleId("city_radius"),
        center: LatLng(start.latitude, start.longitude),
        radius: kPickupCityRadiusKm * 1000,
        fillColor: Colors.blue.withValues(alpha: 0.08),
        strokeColor: Colors.blue.withValues(alpha: 0.5),
        strokeWidth: 2,
      ),
    };
  }

  Set<Marker> get markers => {
    if (startPoint != null)
      Marker(
        markerId: const MarkerId("start"),
        position: LatLng(startPoint!.latitude, startPoint!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    if (endPoint != null)
      Marker(
        markerId: const MarkerId("end"),
        position: LatLng(endPoint!.latitude, endPoint!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
  };

  /// مسارات الطرق: المختار بارز، والبدائل رمادية وقابلة للضغط للتبديل. إن تعذّر
  /// جلبها (لا مفتاح/فشل) يُرسم خط مستقيم تقريبي.
  Set<Polyline> get polylines {
    // نقرأ القيم المراقَبة أولًا دائمًا كي لا يرمي Obx خطأ "improper use"
    // عندما نخرج مبكرًا (allowRoutePickup=false).
    final selected = selectedRoute.value;
    final hasRoutes = routes.isNotEmpty;
    if (!allowRoutePickup || startPoint == null || endPoint == null) return {};
    if (hasRoutes) {
      return {
        for (var i = 0; i < routes.length; i++)
          Polyline(
            polylineId: PolylineId("route_$i"),
            points: routes[i].points,
            color: i == selected ? Colors.blue : Colors.grey.shade500,
            width: i == selected ? 7 : 5,
            zIndex: i == selected ? 2 : 1,
            consumeTapEvents: true,
            onTap: () => selectRoute(i),
          ),
      };
    }
    return {
      Polyline(
        polylineId: const PolylineId("route"),
        points: [
          LatLng(startPoint!.latitude, startPoint!.longitude),
          LatLng(endPoint!.latitude, endPoint!.longitude),
        ],
        color: Colors.blue.withValues(alpha: 0.6),
        width: 4,
        patterns: [PatternItem.dash(16), PatternItem.gap(10)],
      ),
    };
  }

  Future<void> useMyLocation() async {
    if (locating.value) return;
    locating.value = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _warn("pickup_location_services_disabled".tr);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _warn("pickup_location_permission_denied".tr);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final point = LatLng(position.latitude, position.longitude);
      _gpsPoint = point;
      center.value = point;
      await mapController?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
    } catch (_) {
      _warn("pickup_location_failed".tr);
    } finally {
      locating.value = false;
    }
  }

  void _warn(String message) =>
      CustomToasts(message: message, type: CustomToastType.warning).show();

  /// المسافة بالمتر (تقريب مسطح يكفي لمقارنة نقطة GPS بمركز الخريطة).
  static double _meters(LatLng a, LatLng b) {
    const k = 111320.0;
    final dLat = (a.latitude - b.latitude) * k;
    final dLng =
        (a.longitude - b.longitude) * k * math.cos(a.latitude * math.pi / 180);
    return math.sqrt(dLat * dLat + dLng * dLng);
  }

  /// "الاسم، المنطقة — ملاحظة الراكب للسائق".
  String _address() {
    final label = [
      placeTitle.value,
      placeRegion.value,
    ].where((e) => e.trim().isNotEmpty).join("، ");
    final note = addressController.text.trim();
    if (note.isEmpty) return label;
    return label.isEmpty ? note : "$label — $note";
  }

  void confirm() {
    final point = center.value;
    if (point == null) return;
    final start = startPoint;
    if (start != null &&
        _meters(LatLng(start.latitude, start.longitude), point) >
            kPickupCityRadiusKm * 1000) {
      _warn("pickup_outside_radius".tr);
      return;
    }
    // gps إذا بقي المركز على موقعي الحالي، وإلا pin.
    final isGps = _gpsPoint != null && _meters(_gpsPoint!, point) < 5;
    Get.back(
      result: PickupDto.location(
        source: isGps ? "gps" : "pin",
        latitude: double.parse(point.latitude.toStringAsFixed(7)),
        longitude: double.parse(point.longitude.toStringAsFixed(7)),
        address: _address(),
      ),
    );
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _reverseDebounce?.cancel();
    addressController.dispose();
    searchController.dispose();
    searchFocus.dispose();
    mapController?.dispose();
    super.onClose();
  }
}
