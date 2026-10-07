/// لا يوجد حقل رابط (URL) إطلاقًا — التنزيل يمر دومًا عبر
/// GET .../documents/{documentId} (راجع visa_repo.dart)، لا رابط يُخزَّن أو يُعاد استخدامه.
class VisaDocumentModel {
  final int documentId;
  final String documentType;
  final int? fieldId;
  final String originalName;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime? uploadedAt;

  const VisaDocumentModel({
    required this.documentId,
    required this.documentType,
    this.fieldId,
    required this.originalName,
    this.mimeType,
    this.sizeBytes,
    this.uploadedAt,
  });

  factory VisaDocumentModel.fromJson(Map<String, dynamic> json) =>
      VisaDocumentModel(
        documentId: json["document_id"],
        documentType: json["document_type"]?.toString() ?? "",
        fieldId: json["field_id"],
        originalName: json["original_name"]?.toString() ?? "",
        mimeType: json["mime_type"]?.toString(),
        sizeBytes: json["size_bytes"],
        uploadedAt: json["uploaded_at"] != null
            ? DateTime.tryParse(json["uploaded_at"])
            : null,
      );
}
