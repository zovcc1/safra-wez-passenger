import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/dto/trip_search_dto.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/governorate_model.dart';
import 'package:safraa_passenger_app/data/models/trip_search_result_model.dart';
import 'package:safraa_passenger_app/data/repos/reference_repo.dart';
import 'package:safraa_passenger_app/data/repos/trips_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';

/// خيارات نوع المركبة المعروضة بالفلتر — لا يوجد Endpoint لقائمة الأنواع
/// حاليًا، فالقيم هنا slugs بنيوية تُرسل كما هي (راجع القسم 8 من المواصفات).
class VehicleTypeOption {
  final String? slug;
  final String label;

  const VehicleTypeOption({required this.slug, required this.label});
}

class TripsPageController extends GetxController {
  final ReferenceRepo referenceRepo = Get.find<ReferenceRepo>();
  final TripsRepo tripsRepo = Get.find<TripsRepo>();

  final scrollController = ScrollController();

  /// مرساة بداية قسم النتائج: يتمرّر إليها بعد كل بحث ناجح.
  final resultsAnchorKey = GlobalKey();

  final governoratesLoadingState = LoadingState.idle.obs;
  final governorates = <GovernorateModel>[].obs;

  final originGovernorate = Rxn<GovernorateModel>();
  final destinationGovernorate = Rxn<GovernorateModel>();
  final departureDateFrom = Rxn<DateTime>();
  final departureDateTo = Rxn<DateTime>();
  final seatsNeeded = Rxn<int>();
  final vehicleType = Rxn<String>();

  final searchExpanded = true.obs;

  final loadingState = LoadingState.idle.obs;
  final loadingMore = false.obs;
  final results = <TripSearchResultModel>[].obs;
  String? _nextCursor;
  bool _hasMore = false;
  bool _hasSearchedOnce = false;

  bool get hasSearchedOnce => _hasSearchedOnce;

  static List<VehicleTypeOption> get vehicleTypeOptions => [
    VehicleTypeOption(slug: null, label: "trips_vehicle_all".tr),
    VehicleTypeOption(slug: "car", label: "trips_vehicle_car".tr),
    VehicleTypeOption(slug: "van", label: "trips_vehicle_van".tr),
    VehicleTypeOption(slug: "bus", label: "trips_vehicle_bus".tr),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadGovernorates();
    scrollController.addListener(_onScroll);
  }

  Future<void> _loadGovernorates() async {
    governoratesLoadingState.value = LoadingState.loading;
    final response = await referenceRepo.governorates();
    if (!response.success) {
      governoratesLoadingState.value = LoadingState.hasError;
      return;
    }
    governorates.assignAll(response.data ?? []);
    governoratesLoadingState.value = governorates.isEmpty
        ? LoadingState.doneWithNoData
        : LoadingState.doneWithData;
  }

  void retryLoadGovernorates() => _loadGovernorates();

  void toggleSearchExpanded() => searchExpanded.value = !searchExpanded.value;

  void setOriginGovernorate(GovernorateModel? governorate) {
    originGovernorate.value = governorate;
  }

  void setDestinationGovernorate(GovernorateModel? governorate) {
    destinationGovernorate.value = governorate;
  }

  void swapGovernorates() {
    final origin = originGovernorate.value;
    originGovernorate.value = destinationGovernorate.value;
    destinationGovernorate.value = origin;
  }

  Future<void> pickDepartureDateFrom(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: departureDateFrom.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    departureDateFrom.value = picked;
    if (departureDateTo.value != null &&
        departureDateTo.value!.isBefore(picked)) {
      departureDateTo.value = null;
    }
  }

  Future<void> pickDepartureDateTo(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          departureDateTo.value ?? departureDateFrom.value ?? DateTime.now(),
      firstDate: departureDateFrom.value ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    departureDateTo.value = picked;
  }

  void clearDepartureDateFrom() => departureDateFrom.value = null;

  void clearDepartureDateTo() => departureDateTo.value = null;

  void setSeatsNeeded(int? seats) => seatsNeeded.value = seats;

  void setVehicleType(String? slug) => vehicleType.value = slug;

  Future<void> search() async {
    if (originGovernorate.value == null ||
        destinationGovernorate.value == null) {
      CustomToasts(
        message: "trips_validation_choose_governorates".tr,
        type: CustomToastType.warning,
      ).show();
      return;
    }
    if (originGovernorate.value!.governorateId ==
        destinationGovernorate.value!.governorateId) {
      CustomToasts(
        message: "trips_validation_different_governorates".tr,
        type: CustomToastType.warning,
      ).show();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    _hasSearchedOnce = true;
    _nextCursor = null;
    _hasMore = false;
    loadingState.value = LoadingState.loading;
    results.clear();

    await _fetch();
    if (results.isNotEmpty) _scrollToResults();
  }

  void _scrollToResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final anchor = resultsAnchorKey.currentContext;
      if (anchor == null) return;
      Scrollable.ensureVisible(
        anchor,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
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

  Future<void> reload() async {
    if (originGovernorate.value == null ||
        destinationGovernorate.value == null) {
      await _loadGovernorates();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    _hasSearchedOnce = true;
    _nextCursor = null;
    _hasMore = false;
    loadingState.value = LoadingState.loading;
    results.clear();
    await _fetch();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final threshold = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= threshold) {
      loadMore();
    }
  }

  Future<void> _fetch() async {
    final dto = TripSearchDto(
      originGovernorateId: originGovernorate.value!.governorateId,
      destinationGovernorateId: destinationGovernorate.value!.governorateId,
      departureDateFrom: departureDateFrom.value,
      departureDateTo: departureDateTo.value,
      seatsNeeded: seatsNeeded.value,
      vehicleType: vehicleType.value,
      cursor: _nextCursor,
    );

    final response = await tripsRepo.search(dto);

    if (!response.success) {
      if (results.isEmpty) {
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
    results.addAll(page.items);
    _nextCursor = page.nextCursor;
    _hasMore = page.hasMore;
    loadingState.value = results.isEmpty
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
