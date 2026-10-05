import 'package:safraa_passenger_app/data/models/visa_country_model.dart';
import 'package:safraa_passenger_app/data/models/visa_document_model.dart';

/// نفس الصنف يُستخدم لعنصر القائمة (أخف) وشاشة التفاصيل (أغنى) — الحقول
/// الخاصة بالتفاصيل فقط (adminNote, allowedActions, documents) تُقرأ كـ
/// null/فارغة إن غابت، لكن شاشة التفاصيل تعتبر غياب allowedActions هناك خطأ
/// بالعقد يُبلَّغ عنه لا حالة تُشتق من status محليًا.
class VisaRequestModel {
  final int id;
  final String status;
  final VisaCountryModel? country;
  final String expectedPrice;
  final String? adminNote;
  final int? templateId;
  final DateTime? createdAt;
  final List<String> allowedActions;
  final List<VisaDocumentModel> documents;

  const VisaRequestModel({
    required this.id,
    required this.status,
    this.country,
    required this.expectedPrice,
    this.adminNote,
    this.templateId,
    this.createdAt,
    required this.allowedActions,
    required this.documents,
  });

  factory VisaRequestModel.fromJson(Map<String, dynamic> json) =>
      VisaRequestModel(
        id: json["id"] ?? 0,
        status: json["status"] ?? "",
        country: json["country"] is Map
            ? VisaCountryModel.fromJson(
                Map<String, dynamic>.from(json["country"]),
              )
            : null,
        expectedPrice: json["expected_price"]?.toString() ?? "0.00",
        adminNote: json["admin_note"],
        templateId: json["template_id"],
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        allowedActions: List<String>.from(
          (json["allowed_actions"] ?? const []).map((e) => e.toString()),
        ),
        documents: List<Map<String, dynamic>>.from(
          json["documents"] ?? const [],
        ).map(VisaDocumentModel.fromJson).toList(),
      );
}
