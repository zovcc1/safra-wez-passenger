import 'package:safraa_passenger_app/presentation/util/utils.dart';

/// لا يوجد حقل رابط (URL) إطلاقًا — التنزيل يمر دومًا عبر
/// GET .../documents/{documentId} (راجع visa_repo.dart)، لا رابط يُخزَّن أو يُعاد استخدامه.
class VisaDocumentModel {
  final int documentId;
  final String fieldKey;
  final Map<String, dynamic> label;

  const VisaDocumentModel({
    required this.documentId,
    required this.fieldKey,
    required this.label,
  });

  String get displayLabel => Utils.parseLocalizedName(label);

  factory VisaDocumentModel.fromJson(Map<String, dynamic> json) =>
      VisaDocumentModel(
        documentId: json["document_id"] ?? json["id"],
        fieldKey: json["field_key"]?.toString() ?? "",
        label: json["label"] is Map
            ? Map<String, dynamic>.from(json["label"])
            : {},
      );
}
