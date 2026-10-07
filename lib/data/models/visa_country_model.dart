import 'package:safraa_passenger_app/presentation/util/utils.dart';

class VisaCountryModel {
  final int id;
  final Map<String, dynamic> name;
  final String visaPrice;
  final String? currency;
  final int? templateId;
  final int? formVersion;

  const VisaCountryModel({
    required this.id,
    required this.name,
    required this.visaPrice,
    this.currency,
    this.templateId,
    this.formVersion,
  });

  String get displayName => Utils.parseLocalizedName(name);

  /// staging يرجع country_id و price (لا id و visa_price) — نقبل الشكلين.
  factory VisaCountryModel.fromJson(Map<String, dynamic> json) =>
      VisaCountryModel(
        id: json["country_id"] ?? json["id"],
        name: json["name"] is Map
            ? Map<String, dynamic>.from(json["name"])
            : {},
        visaPrice: (json["price"] ?? json["visa_price"])?.toString() ?? "0.00",
        currency: json["currency"]?.toString(),
        templateId: json["template_id"],
        formVersion: json["form_version"],
      );
}
