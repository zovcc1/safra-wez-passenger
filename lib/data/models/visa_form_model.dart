import 'package:safraa_passenger_app/data/models/visa_field_model.dart';
import 'package:safraa_passenger_app/presentation/util/utils.dart';

class VisaFormModel {
  final int countryId;
  final int templateId;
  final int version;
  final Map<String, dynamic> title;
  final List<VisaFieldModel> fields;

  const VisaFormModel({
    required this.countryId,
    required this.templateId,
    required this.version,
    required this.title,
    required this.fields,
  });

  String get displayTitle => Utils.parseLocalizedName(title);

  /// الحقول مرتّبة حسب display_order.
  factory VisaFormModel.fromJson(Map<String, dynamic> json) => VisaFormModel(
    countryId: json["country_id"] ?? 0,
    templateId: json["template_id"] ?? 0,
    version: json["version"] ?? 0,
    title: json["title"] is Map ? Map<String, dynamic>.from(json["title"]) : {},
    fields:
        List<Map<String, dynamic>>.from(
          (json["fields"] ?? const []).map((e) => Map<String, dynamic>.from(e)),
        ).map(VisaFieldModel.fromJson).toList()..sort(
          (a, b) => a.displayOrder.compareTo(b.displayOrder),
        ),
  );
}
