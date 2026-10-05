import 'dart:convert';

import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/dto/create_booking_dto.dart';
import 'package:safraa_passenger_app/data/dto/pickup_dto.dart';
import 'package:safraa_passenger_app/data/dto/submit_rating_dto.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/data/models/cursor_paginated_response.dart';

class BookingsRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  /// POST /passenger/bookings — راجع القسم 9.1.
  Future<AppResponse<BookingModel>> create(CreateBookingDto dto) async {
    AppResponse<BookingModel> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.bookings,
        method: Method.post,
        requiredToken: true,
        params: jsonEncode(dto.toJson()),
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = BookingModel.fromJson(
          Map<String, dynamic>.from(json["data"] ?? {}),
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

  /// GET /passenger/bookings — راجع القسم 9.2.
  Future<AppResponse<CursorPaginatedResponse<BookingModel>>> list({
    String? cursor,
  }) async {
    AppResponse<CursorPaginatedResponse<BookingModel>> appResponse =
        AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.bookings,
        method: Method.get,
        requiredToken: true,
        queryParameters: cursor == null ? null : {"cursor": cursor},
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        final data = Map<String, dynamic>.from(json["data"] ?? {});
        // شكل استجابة القائمة يسمّي المفتاح "bookings" لا "items" (خلافًا لبحث
        // الرحلات)، فنطبّعه هنا قبل تمريره لـ CursorPaginatedResponse.fromJson.
        appResponse.data = CursorPaginatedResponse.fromJson({
          "items": data["bookings"],
          "next_cursor": data["next_cursor"],
          "has_more": data["next_cursor"] != null,
        }, BookingModel.fromJson);
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
    }
    return appResponse;
  }

  /// GET /passenger/bookings/{booking} — راجع القسم 9.3. حجز شخص آخر يعود 404.
  Future<AppResponse<BookingModel>> details(int bookingId) async {
    AppResponse<BookingModel> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.bookingDetails(bookingId),
        method: Method.get,
        requiredToken: true,
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = BookingModel.fromJson(
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

  /// PATCH /passenger/bookings/{booking}/pickup-point — يرجّع الحجز (booking_id،
  /// trip_id، status، pickup) لا الحجز الكامل، فنعيد جلب التفاصيل بعدها.
  Future<AppResponse<BookingPickupModel>> changePickup(
    int bookingId,
    PickupDto pickup,
  ) async {
    AppResponse<BookingPickupModel> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.bookingPickupPoint(bookingId),
        method: Method.patch,
        requiredToken: true,
        params: jsonEncode({"pickup": pickup.toJson()}),
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        final data = Map<String, dynamic>.from(json["data"] ?? {});
        appResponse.data = BookingPickupModel.fromJson(
          Map<String, dynamic>.from(data["pickup"] ?? {}),
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

  /// GET /passenger/bookings/{booking}/tracking — لقطة التتبع. تُستدعى عند فتح
  /// الشاشة وبعد كل إعادة اتصال بالـ socket.
  Future<AppResponse<TrackingSnapshotModel>> tracking(int bookingId) async {
    AppResponse<TrackingSnapshotModel> appResponse = AppResponse(
      success: false,
    );
    try {
      final response = await apiService.request(
        url: Api.bookingTracking(bookingId),
        method: Method.get,
        requiredToken: true,
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = TrackingSnapshotModel.fromJson(
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

  /// POST /passenger/bookings/{booking}/rating — يرجّع الحجز كاملًا بعد إضافة
  /// التقييم (can_rate=false و rating معبّأ).
  Future<AppResponse<BookingModel>> rate(
    int bookingId,
    SubmitRatingDto dto,
  ) async {
    AppResponse<BookingModel> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: Api.bookingRating(bookingId),
        method: Method.post,
        requiredToken: true,
        params: jsonEncode(dto.toJson()),
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = BookingModel.fromJson(
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
