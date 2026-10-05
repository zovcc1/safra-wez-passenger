import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/complaint_category_model.dart';
import 'package:safraa_passenger_app/data/models/governorate_model.dart';

/// بيانات مرجعية عامة (لا تتطلب توكن)، مصدر واحد يشترك به الراكب والمزوّد
/// والإدارة — راجع GET /reference/governorates.
class ReferenceRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  /// التصنيفات ثابتة طوال الجلسة؛ نخزّنها بعد أول نجاح لعرض أسماء التصنيفات في
  /// القائمة والتفاصيل بدون طلب متكرر.
  List<ComplaintCategoryModel>? _complaintCategoriesCache;

  Future<AppResponse<List<GovernorateModel>>> governorates() async {
    AppResponse<List<GovernorateModel>> appResponse = AppResponse(
      success: false,
    );
    try {
      final response = await apiService.request(
        url: Api.governorates,
        method: Method.get,
        requiredToken: false,
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = List<Map<String, dynamic>>.from(
          json["data"] ?? const [],
        ).map(GovernorateModel.fromJson).toList();
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
    }
    return appResponse;
  }

  /// GET /reference/complaint-categories — عام، اللغتان تعودان معًا.
  Future<AppResponse<List<ComplaintCategoryModel>>>
  complaintCategories() async {
    AppResponse<List<ComplaintCategoryModel>> appResponse = AppResponse(
      success: false,
    );
    final cached = _complaintCategoriesCache;
    if (cached != null) {
      return appResponse
        ..success = true
        ..data = cached;
    }
    try {
      final response = await apiService.request(
        url: Api.complaintCategories,
        method: Method.get,
        requiredToken: false,
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = List<Map<String, dynamic>>.from(
          json["data"] ?? const [],
        ).map(ComplaintCategoryModel.fromJson).toList();
        _complaintCategoriesCache = appResponse.data;
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
    }
    return appResponse;
  }
}
