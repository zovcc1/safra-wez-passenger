import 'package:safraa_passenger_app/data/models/visa_country_model.dart';
import 'package:safraa_passenger_app/data/models/visa_document_model.dart';
import 'package:safraa_passenger_app/data/models/visa_form_model.dart';

/// نفس الصنف يُستخدم لعنصر القائمة (قد يكون أخف) وشاشة التفاصيل — الحقول
/// الخاصة بالتفاصيل (form, values, documents, ...) تُقرأ كفارغة إن غابت.
/// أزرار الواجهة تُشتق من status (لا يوجد allowed_actions بالعقد).
class VisaRequestModel {
  final int id;
  final String status;
  final VisaCountryModel? country;
  final String quotedAmount;
  final String? currency;
  final String? paymentMethod;
  final String? adminNote;
  final String? visaProviderName;
  final VisaFormModel? form;
  final Map<int, String> values;
  final List<VisaDocumentModel> documents;
  final DateTime? submittedAt;
  final DateTime? assignedAt;
  final DateTime? decidedAt;
  final DateTime? deliveredAt;

  const VisaRequestModel({
    required this.id,
    required this.status,
    this.country,
    required this.quotedAmount,
    this.currency,
    this.paymentMethod,
    this.adminNote,
    this.visaProviderName,
    this.form,
    this.values = const {},
    required this.documents,
    this.submittedAt,
    this.assignedAt,
    this.decidedAt,
    this.deliveredAt,
  });

  int? get templateId => form?.templateId;

  /// مستندات غير مرفوعة من المسافر (مثل مستندات التسليم) — مرفقات الحقول
  /// تُعرض داخل بطاقة بيانات الطلب بمكان حقولها.
  List<VisaDocumentModel> get otherDocuments => documents
      .where((d) => d.documentType != "applicant_document" || d.fieldId == null)
      .toList();

  bool get hasTimeline =>
      submittedAt != null ||
      assignedAt != null ||
      decidedAt != null ||
      deliveredAt != null;

  bool get canEdit => status == "submitted";
  bool get canResubmit => status == "needs_info";
  bool get canWithdraw =>
      status == "submitted" ||
      status == "under_review" ||
      status == "needs_info";

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  factory VisaRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => VisaRequestModel(
    id: json["request_id"] ?? 0,
    status: json["status"] ?? "",
    country: json["country"] is Map
        ? VisaCountryModel.fromJson(Map<String, dynamic>.from(json["country"]))
        : null,
    quotedAmount: json["quoted_amount"]?.toString() ?? "0.00",
    currency: json["currency"]?.toString(),
    paymentMethod: json["payment_method"]?.toString(),
    adminNote: json["admin_note"],
    visaProviderName: json["visa_provider"] is Map
        ? json["visa_provider"]["name"]?.toString()
        : null,
    form: json["form"] is Map
        ? VisaFormModel.fromJson(Map<String, dynamic>.from(json["form"]))
        : null,
    values: {
      for (final v in (json["values"] as List? ?? const []).whereType<Map>())
        if (v["field_id"] != null) v["field_id"] as int: "${v["value"] ?? ""}",
    },
    documents: List<Map<String, dynamic>>.from(
      (json["documents"] ?? const []).map((e) => Map<String, dynamic>.from(e)),
    ).map(VisaDocumentModel.fromJson).toList(),
    submittedAt: _date(json["submitted_at"]),
    assignedAt: _date(json["assigned_at"]),
    decidedAt: _date(json["decided_at"]),
    deliveredAt: _date(json["delivered_at"]),
  );
}
