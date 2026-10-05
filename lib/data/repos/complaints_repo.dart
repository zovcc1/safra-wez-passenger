import 'dart:convert';

import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/dto/file_complaint_dto.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/complaint_model.dart';
import 'package:safraa_passenger_app/data/models/cursor_paginated_response.dart';

class ComplaintsRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  Future<AppResponse<T>> _run<T>(
    Future<dynamic> Function() call,
    T Function(dynamic data) parse,
  ) async {
    AppResponse<T> appResponse = AppResponse(success: false);
    try {
      final response = await call();
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = parse(json["data"]);
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

  /// POST /passenger/complaints — throttle: 5 كل 10 دقائق (429).
  Future<AppResponse<ComplaintModel>> file(FileComplaintDto dto) => _run(
    () => apiService.request(
      url: Api.complaints,
      method: Method.post,
      requiredToken: true,
      params: jsonEncode(dto.toJson()),
    ),
    (data) => ComplaintModel.fromJson(Map<String, dynamic>.from(data ?? {})),
  );

  /// GET /passenger/complaints
  Future<AppResponse<CursorPaginatedResponse<ComplaintModel>>> list({
    String? cursor,
  }) => _run(
    () => apiService.request(
      url: Api.complaints,
      method: Method.get,
      requiredToken: true,
      queryParameters: cursor == null ? null : {"cursor": cursor},
    ),
    (data) => CursorPaginatedResponse.fromJson(
      Map<String, dynamic>.from(data ?? {}),
      ComplaintModel.fromJson,
    ),
  );

  /// GET /passenger/complaints/{complaint} — شكوى مسافر آخر تعود 404.
  Future<AppResponse<ComplaintModel>> details(int complaintId) => _run(
    () => apiService.request(
      url: Api.complaintDetails(complaintId),
      method: Method.get,
      requiredToken: true,
    ),
    (data) => ComplaintModel.fromJson(Map<String, dynamic>.from(data ?? {})),
  );

  /// GET /passenger/complaints/{complaint}/replies — الردود العامة فقط.
  Future<AppResponse<CursorPaginatedResponse<ComplaintReplyModel>>> replies(
    int complaintId, {
    String? cursor,
  }) => _run(
    () => apiService.request(
      url: Api.complaintReplies(complaintId),
      method: Method.get,
      requiredToken: true,
      queryParameters: cursor == null ? null : {"cursor": cursor},
    ),
    (data) => CursorPaginatedResponse.fromJson(
      Map<String, dynamic>.from(data ?? {}),
      ComplaintReplyModel.fromJson,
    ),
  );

  /// POST /passenger/complaints/{complaint}/replies — مسموح بكل الحالات (201)،
  /// وبعده يلزم refetch للشكوى لأن response لا يحمل الحالة الجديدة.
  Future<AppResponse<ComplaintReplyModel>> addReply(
    int complaintId,
    String body,
  ) => _run(
    () => apiService.request(
      url: Api.complaintReplies(complaintId),
      method: Method.post,
      requiredToken: true,
      params: jsonEncode({"body": body.trim()}),
    ),
    (data) =>
        ComplaintReplyModel.fromJson(Map<String, dynamic>.from(data ?? {})),
  );
}
