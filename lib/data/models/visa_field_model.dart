import 'package:safraa_passenger_app/presentation/util/utils.dart';

class VisaFieldModel {
  final int fieldId;
  final String fieldKey;
  final Map<String, dynamic> label;
  final String type;
  final bool required;

  const VisaFieldModel({
    required this.fieldId,
    required this.fieldKey,
    required this.label,
    required this.type,
    required this.required,
  });

  String get displayLabel => Utils.parseLocalizedName(label);

  factory VisaFieldModel.fromJson(Map<String, dynamic> json) => VisaFieldModel(
    fieldId: json["field_id"],
    fieldKey: json["field_key"]?.toString() ?? "",
    label: json["label"] is Map ? Map<String, dynamic>.from(json["label"]) : {},
    type: json["type"]?.toString() ?? "text",
    required: json["required"] == true,
  );
}
