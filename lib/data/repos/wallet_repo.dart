import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/cursor_paginated_response.dart';
import 'package:safraa_passenger_app/data/models/wallet_model.dart';
import 'package:safraa_passenger_app/data/models/wallet_transaction_model.dart';

class WalletRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  /// GET /passenger/wallet. 404 = لا توجد محفظة مرتبطة بالحساب.
  Future<AppResponse<WalletModel>> wallet() async {
    AppResponse<WalletModel> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.wallet,
        method: Method.get,
        requiredToken: true,
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = WalletModel.fromJson(
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

  /// GET /passenger/wallet/transactions. [from]/[to] بصيغة YYYY-MM-DD.
  Future<AppResponse<CursorPaginatedResponse<WalletTransactionModel>>>
  transactions({
    List<String> types = const [],
    String? from,
    String? to,
    String? cursor,
  }) async {
    AppResponse<CursorPaginatedResponse<WalletTransactionModel>> appResponse =
        AppResponse(success: false);
    try {
      final query = <String, dynamic>{
        // Dio يكرّر المفتاح كما هو (type=a&type=b)، أما Laravel فيتوقع type[].
        if (types.isNotEmpty) "type[]": types,
        if (from != null) "from": from,
        if (to != null) "to": to,
        if (cursor != null) "cursor": cursor,
      };
      final response = await apiService.request(
        url: Api.walletTransactions,
        method: Method.get,
        requiredToken: true,
        queryParameters: query.isEmpty ? null : query,
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = CursorPaginatedResponse.fromJson(
          Map<String, dynamic>.from(json["data"] ?? {}),
          WalletTransactionModel.fromJson,
        );
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
        appResponse.fieldErrors = AppResponse.extractFieldErrors(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
    }
    return appResponse;
  }
}
