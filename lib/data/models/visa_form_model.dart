import 'package:safraa_passenger_app/data/models/visa_field_model.dart';

class VisaFormModel {
  final int countryId;
  final int templateId;
  final String visaPrice;
  final List<VisaFieldModel> fields;

  const VisaFormModel({
    required this.countryId,
    required this.templateId,
    required this.visaPrice,
    required this.fields,
  });

  factory VisaFormModel.fromJson(Map<String, dynamic> json) => VisaFormModel(
    countryId: json["country_id"],
    templateId: json["template_id"],
    visaPrice: json["visa_price"]?.toString() ?? "0.00",
    fields: List<Map<String, dynamic>>.from(
      json["fields"] ?? const [],
    ).map(VisaFieldModel.fromJson).toList(),
  );
}
