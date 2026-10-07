import 'package:safraa_passenger_app/presentation/util/utils.dart';

/// field_type: text | date | file | select فقط.
class VisaFieldModel {
  final int fieldId;
  final String fieldKey;
  final Map<String, dynamic> label;
  final String type;
  final bool required;
  final int displayOrder;
  final List<Map<String, dynamic>> options;

  const VisaFieldModel({
    required this.fieldId,
    required this.fieldKey,
    required this.label,
    required this.type,
    required this.required,
    this.displayOrder = 0,
    this.options = const [],
  });

  String get displayLabel => Utils.parseLocalizedName(label);

  factory VisaFieldModel.fromJson(Map<String, dynamic> json) => VisaFieldModel(
    fieldId: json["field_id"],
    fieldKey: json["field_key"]?.toString() ?? "",
    label: json["label"] is Map ? Map<String, dynamic>.from(json["label"]) : {},
    type: json["field_type"]?.toString() ?? "text",
    required: json["is_required"] == true,
    displayOrder: json["display_order"] ?? 0,
    options: json["options"] is List
        ? (json["options"] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : const [],
  );
}
