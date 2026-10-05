import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_country_model.dart';
import 'package:safraa_passenger_app/data/repos/visa_repo.dart';

class VisaCountriesPageController extends GetxController {
  final VisaRepo visaRepo = Get.find<VisaRepo>();

  final loadingState = LoadingState.idle.obs;
  final countries = <VisaCountryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loadingState.value = LoadingState.loading;
    final response = await visaRepo.countries();
    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      return;
    }
    countries.assignAll(response.data ?? []);
    loadingState.value = countries.isEmpty
        ? LoadingState.doneWithNoData
        : LoadingState.doneWithData;
  }

  Future<void> retry() => _load();
}
