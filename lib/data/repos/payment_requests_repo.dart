import 'dart:convert';

import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/cursor_paginated_response.dart';
import 'package:safraa_passenger_app/data/models/payment_request_model.dart';

class PaymentRequestsRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  /// GET / — القائمة داخل data.payment_requests، الأحدث أولًا، status اختياري.
  Future<AppResponse<CursorPaginatedResponse<PaymentRequestModel>>> list({
    String? cursor,
    String? status,
  }) async {
    AppResponse<CursorPaginatedResponse<PaymentRequestModel>> appResponse =
        AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.paymentRequests,
        method: Method.get,
        requiredToken: true,
        queryParameters: {
          if (cursor != null) "cursor": cursor,
          if (status != null) "status": status,
        },
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        final data = Map<String, dynamic>.from(json["data"] ?? {});
        appResponse.data = CursorPaginatedResponse.fromJson({
          "items": data["payment_requests"],
          "next_cursor": data["next_cursor"],
          "has_more": data["next_cursor"] != null,
        }, PaymentRequestModel.fromJson);
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
    }
    return appResponse;
  }

  Future<AppResponse<PaymentRequestModel>> details(int id) =>
      _call(url: Api.paymentRequestDetails(id), method: Method.get);

  /// POST /{id}/approve — يجمّد المبلغ من المحفظة. المفتاح واحد لكل نيّة ويُعاد
  /// استخدامه عند المحاولة بعد شحن الرصيد.
  Future<AppResponse<PaymentRequestModel>> approve(
    int id,
    String idempotencyKey,
  ) => _call(
    url: Api.paymentRequestApprove(id),
    method: Method.post,
    params: {"idempotency_key": idempotencyKey},
  );

  Future<AppResponse<PaymentRequestModel>> reject(
    int id,
    String idempotencyKey,
  ) => _call(
    url: Api.paymentRequestReject(id),
    method: Method.post,
    params: {"idempotency_key": idempotencyKey},
  );

  Future<AppResponse<PaymentRequestModel>> _call({
    required String url,
    required Method method,
    Map<String, dynamic>? params,
  }) async {
    AppResponse<PaymentRequestModel> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: url,
        method: method,
        requiredToken: true,
        params: params == null ? null : jsonEncode(params),
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = PaymentRequestModel.fromJson(
          Map<String, dynamic>.from(json["data"] ?? {}),
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
}
