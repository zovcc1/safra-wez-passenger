import 'dart:convert';

import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/cursor_paginated_response.dart';
import 'package:safraa_passenger_app/data/models/notification_models.dart';

class NotificationsRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  /// GET /passenger/notifications — status=read|unread اختياري.
  Future<AppResponse<CursorPaginatedResponse<NotificationItemModel>>> list({
    String? cursor,
    String? status,
  }) async {
    AppResponse<CursorPaginatedResponse<NotificationItemModel>> appResponse =
        AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.notifications,
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
          "items": data["notifications"],
          "next_cursor": data["next_cursor"],
          "has_more": data["next_cursor"] != null,
        }, NotificationItemModel.fromJson);
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
    }
    return appResponse;
  }

  /// POST /passenger/notifications/{id}/read — idempotent، بلا body.
  /// 404 = غير موجود أو يخص راكبًا آخر.
  Future<AppResponse<void>> markRead(int notificationId) async {
    final AppResponse<void> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.notificationRead(notificationId),
        method: Method.post,
        requiredToken: true,
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (!appResponse.success) {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
    }
    return appResponse;
  }

  Future<AppResponse<List<NotificationPreferenceModel>>> preferences() =>
      _preferences(Method.get, null);

  /// PUT جزئي: أرسل ما تغيّر فقط.
  Future<AppResponse<List<NotificationPreferenceModel>>> updatePreference(
    String category,
    bool enabled,
  ) => _preferences(Method.put, {
    "preferences": [
      {"category": category, "enabled": enabled},
    ],
  });

  Future<AppResponse<List<NotificationPreferenceModel>>> _preferences(
    Method method,
    Map<String, dynamic>? params,
  ) async {
    AppResponse<List<NotificationPreferenceModel>> appResponse = AppResponse(
      success: false,
    );
    try {
      final response = await apiService.request(
        url: Api.notificationPreferences,
        method: method,
        requiredToken: true,
        params: params == null ? null : jsonEncode(params),
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        final data = Map<String, dynamic>.from(json["data"] ?? {});
        appResponse.data = List<Map<String, dynamic>>.from(
          (data["preferences"] as List? ?? const []).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        ).map(NotificationPreferenceModel.fromJson).toList();
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
