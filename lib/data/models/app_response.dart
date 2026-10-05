import '../../core/services/network_service/network_failure_model.dart';

class AppResponse<T> {
  bool success;
  T? data;
  String? _errorMessage;
  String? successMessage;
  NetworkFailureModel? networkFailure;

  /// أخطاء 422 مفصّلة لكل حقل، مثال: {"phone_number": ["Invalid format"]}.
  /// تُستخدم لعرض الخطأ تحت الحقل المطابق بدل الاكتفاء برسالة عامة مدمجة.
  Map<String, List<String>>? fieldErrors;

  set errorMessage(String value) {
    _errorMessage = value;
  }

  String getErrorMessage() {
    return _errorMessage ?? networkFailure?.message ?? "•Unknown error";
  }

  /// أول رسالة خطأ لحقل معيّن، أو null إن لم يُرجع الخادم خطأً لهذا الحقل.
  String? fieldError(String field) => fieldErrors?[field]?.firstOrNull;

  AppResponse({required this.success, this.data, this.networkFailure});

  static Map<String, List<String>>? extractFieldErrors(
    Map<String, dynamic> json,
  ) {
    final errors = json["errors"];
    if (errors is! Map) return null;
    return errors.map(
      (key, value) => MapEntry(
        key.toString(),
        (value is List ? value : [value]).map((e) => e.toString()).toList(),
      ),
    );
  }

  /// يبني رسالة الخطأ من استجابة فيها message عام + errors تفصيلية على شكل
  /// {field: [msg1, msg2]} (شكل Laravel القياسي لأخطاء الـvalidation) —
  /// يدمج رسائل الحقول مع الرسالة العامة بدل تجاهلها.
  static String extractErrorMessage(Map<String, dynamic> json) {
    final String message = json["message"] ?? "";
    final errors = json["errors"];

    if (errors is Map) {
      final List<String> fieldErrors = errors.values
          .whereType<List>()
          .expand((messages) => messages)
          .map((message) => message.toString())
          .toList();

      if (fieldErrors.isNotEmpty) {
        return message.isEmpty
            ? fieldErrors.join("\n")
            : "$message\n${fieldErrors.join("\n")}";
      }
    }

    return message;
  }
}
