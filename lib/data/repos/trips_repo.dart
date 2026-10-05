import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/dto/trip_search_dto.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/cursor_paginated_response.dart';
import 'package:safraa_passenger_app/data/models/trip_search_result_model.dart';
import 'package:safraa_passenger_app/data/models/trip_seat_model.dart';

class TripsRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  /// GET /passenger/trips/search — عام تمامًا، لا يتطلب توكن.
  Future<AppResponse<CursorPaginatedResponse<TripSearchResultModel>>> search(
    TripSearchDto dto,
  ) async {
    AppResponse<CursorPaginatedResponse<TripSearchResultModel>> appResponse =
        AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.tripsSearch,
        method: Method.get,
        requiredToken: false,
        queryParameters: dto.toQueryParameters(),
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = CursorPaginatedResponse.fromJson(
          Map<String, dynamic>.from(json["data"] ?? {}),
          TripSearchResultModel.fromJson,
        );
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
    }
    return appResponse;
  }

  /// GET /passenger/trips/{trip}/seats — عام بلا توكن، للزوّار وللركّاب
  /// المسجَّلين على السواء. مصدر trip_seat_ids اللازمة لحجز رحلة مجدولة
  /// (راجع القسم 9.1). مرقَّم بالمؤشّر (cursor)؛ صفحة 60 مقعدًا أكبر من أي
  /// سعة أسطول فالصفحة الواحدة هي الحالة الطبيعية، لكن نتابع has_more/
  /// next_cursor احترازًا.
  Future<AppResponse<List<TripSeatModel>>> seats(int tripId) async {
    AppResponse<List<TripSeatModel>> appResponse = AppResponse(success: false);
    try {
      final seats = <TripSeatModel>[];
      String? cursor;
      Map<String, dynamic> json;
      do {
        final response = await apiService.request(
          url: Api.tripSeats(tripId),
          method: Method.get,
          requiredToken: false,
          queryParameters: cursor != null ? {"cursor": cursor} : null,
        );
        json = response.data;
        if (json["success"] != true) break;
        final page = CursorPaginatedResponse.fromJson(
          Map<String, dynamic>.from(json["data"] ?? {}),
          TripSeatModel.fromJson,
        );
        seats.addAll(page.items);
        cursor = page.nextCursor;
        if (!page.hasMore) break;
      } while (cursor != null);

      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = seats;
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
