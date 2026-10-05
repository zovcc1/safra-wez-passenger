import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/core/services/network_service/error_handler.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/data/dto/submit_visa_request_dto.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/cursor_paginated_response.dart';
import 'package:safraa_passenger_app/data/models/visa_country_model.dart';
import 'package:safraa_passenger_app/data/models/visa_form_model.dart';
import 'package:safraa_passenger_app/data/models/visa_request_model.dart';

/// راجع الوثيقة: مسار الركّاب حصرًا للتأشيرات (V1) + تحديث 2026-09-22.
class VisaRepo extends GetxService {
  ApiService apiService = Get.find<ApiService>();

  /// GET /reference/visa/countries — عامّة، بدون توكن. الاستجابة الفعلية على
  /// staging تُغلِّف القائمة بـ {"countries": [...]} داخل data، خلافًا للمثال
  /// المسطَّح بالوثيقة (data: [...] مباشرة) — تأكّدنا من الشكل الحقيقي عبر
  /// تشغيل التطبيق فعليًا مقابل staging.
  Future<AppResponse<List<VisaCountryModel>>> countries() => _call(
    url: Api.visaCountries,
    method: Method.get,
    requiredToken: false,
    parse: (json) {
      final data = json["data"];
      final list = data is Map ? data["countries"] : data;
      return List<Map<String, dynamic>>.from(
        list ?? const [],
      ).map(VisaCountryModel.fromJson).toList();
    },
  );

  /// GET /reference/visa/countries/{country}/form — عامّة. 404 = دولة غير
  /// متاحة، 422 = دولة بلا سعر محدَّد بعد — كلاهما يعود برسالة الخادم عبر
  /// errorMessage دون معالجة خاصة إضافية.
  Future<AppResponse<VisaFormModel>> form(int countryId) => _call(
    url: Api.visaCountryForm(countryId),
    method: Method.get,
    requiredToken: false,
    parse: (data) =>
        VisaFormModel.fromJson(Map<String, dynamic>.from(data["data"] ?? {})),
  );

  /// POST /passenger/visa-requests — multipart. عند 409 (تعارض السعر أو
  /// النسخة) يرجع fieldErrors["current_price"]/["expected_price"].
  Future<AppResponse<VisaRequestModel>> create(SubmitVisaRequestDto dto) =>
      _call(
        url: Api.visaRequests,
        method: Method.post,
        requiredToken: true,
        uploadImage: true,
        paramsBuilder: dto.toFormData,
        parse: (data) => VisaRequestModel.fromJson(
          Map<String, dynamic>.from(data["data"] ?? {}),
        ),
      );

  /// GET /passenger/visa-requests — مؤشّر (cursor) لا صفحات (offset/page).
  /// راجع ملاحظة countries() أعلاه: نفس نمط التغليف بمفتاح باسم المورد
  /// (visa_requests/requests) بدل items مباشرة وارد هنا أيضًا حتى يُتحقَّق منه
  /// فعليًا مقابل staging.
  Future<AppResponse<CursorPaginatedResponse<VisaRequestModel>>> list({
    String? cursor,
  }) => _call(
    url: Api.visaRequests,
    method: Method.get,
    requiredToken: true,
    queryParameters: cursor == null ? null : {"cursor": cursor},
    parse: (json) {
      final page = Map<String, dynamic>.from(json["data"] ?? {});
      final items = page["items"] ?? page["visa_requests"] ?? page["requests"];
      return CursorPaginatedResponse.fromJson({
        "items": items,
        "next_cursor": page["next_cursor"],
        "has_more": page["next_cursor"] != null,
      }, VisaRequestModel.fromJson);
    },
  );

  /// GET /passenger/visa-requests/{id}.
  Future<AppResponse<VisaRequestModel>> details(int id) => _call(
    url: Api.visaRequestDetails(id),
    method: Method.get,
    requiredToken: true,
    parse: (data) => VisaRequestModel.fromJson(
      Map<String, dynamic>.from(data["data"] ?? {}),
    ),
  );

  /// POST /passenger/visa-requests/{id}/resubmit — من needs_info فقط.
  Future<AppResponse<VisaRequestModel>> resubmit(
    int id,
    SubmitVisaRequestDto dto,
  ) => _call(
    url: Api.visaRequestResubmit(id),
    method: Method.post,
    requiredToken: true,
    uploadImage: true,
    paramsBuilder: dto.toFormData,
    parse: (data) => VisaRequestModel.fromJson(
      Map<String, dynamic>.from(data["data"] ?? {}),
    ),
  );

  /// PATCH /passenger/visa-requests/{id} — تعديل، من submitted فقط. 422 بعد
  /// انتهاء الحالة، و409 إن فتحه الأدمن باللحظة نفسها (حالة مختلفة تمامًا عن
  /// تعارض السعر بالإنشاء — الفرق بينهما يُميَّز بكود الحالة
  /// response.networkFailure?.code، لا بشكل fieldErrors، لأن PATCH لا يحمل
  /// مفهوم تعارض سعر إطلاقًا).
  Future<AppResponse<VisaRequestModel>> update(
    int id,
    SubmitVisaRequestDto dto,
  ) => _call(
    url: Api.visaRequestDetails(id),
    method: Method.patch,
    requiredToken: true,
    uploadImage: true,
    paramsBuilder: dto.toFormData,
    parse: (data) => VisaRequestModel.fromJson(
      Map<String, dynamic>.from(data["data"] ?? {}),
    ),
  );

  /// POST /passenger/visa-requests/{id}/withdraw — مسموح قبل assigned فقط.
  Future<AppResponse<VisaRequestModel>> withdraw(int id) => _call(
    url: Api.visaRequestWithdraw(id),
    method: Method.post,
    requiredToken: true,
    parse: (data) => VisaRequestModel.fromJson(
      Map<String, dynamic>.from(data["data"] ?? {}),
    ),
  );

  /// GET /passenger/visa-requests/{id}/documents/{documentId} — الوحيد خارج
  /// الغلاف الموحَّد: يرجع ملفًا (stream) مباشرة، فيُنزَّل بدل تحليله كـ JSON.
  /// قبل delivered يرجع 404 (استثناء يُلتقط بالمستدعي).
  Future<File?> downloadDocument({
    required int requestId,
    required int documentId,
    required String fileName,
    required RxDouble progress,
  }) {
    return apiService.downloadFileToTemp(
      fileUrl: Api.visaRequestDocument(requestId, documentId),
      fileName: fileName,
      requiredToken: true,
      progress: progress,
    );
  }

  /// نداء API موحّد يطبّق نمط {success, message, data, errors} بنفس منطق
  /// auth_repo._call — بما فيه استخراج fieldErrors من جسم استجابات 4xx التي
  /// يرميها Dio كـ DioException (422/403/409) ولا تمر أبدًا بفرع
  /// json["success"] العادي (راجع الملاحظة بـ error_handler.dart).
  Future<AppResponse<T>> _call<T>({
    required String url,
    required Method method,
    required bool requiredToken,
    bool uploadImage = false,
    Map<String, dynamic>? queryParameters,
    Future<Object>? Function()? paramsBuilder,
    required T Function(Map<String, dynamic> data) parse,
  }) async {
    AppResponse<T> appResponse = AppResponse(success: false);
    try {
      final response = await apiService.request(
        url: url,
        method: method,
        requiredToken: requiredToken,
        uploadImage: uploadImage,
        queryParameters: queryParameters,
        params: paramsBuilder == null ? null : await paramsBuilder(),
      );
      final Map<String, dynamic> json = response.data;
      appResponse.success = json["success"] == true;
      if (appResponse.success) {
        appResponse.successMessage = json["message"];
        appResponse.data = parse(json);
      } else {
        appResponse.errorMessage = AppResponse.extractErrorMessage(json);
        appResponse.fieldErrors = AppResponse.extractFieldErrors(json);
      }
    } catch (e) {
      appResponse.success = false;
      appResponse.networkFailure = ErrorHandler.handle(e).failure;
      if (e is DioException && e.response?.data is Map) {
        final data = Map<String, dynamic>.from(e.response!.data);
        appResponse.fieldErrors = AppResponse.extractFieldErrors(data);
      }
    }
    return appResponse;
  }
}
