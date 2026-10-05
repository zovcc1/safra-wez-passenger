import 'package:safraa_passenger_app/presentation/util/utils.dart';

class VisaCountryModel {
  final int id;
  final Map<String, dynamic> name;
  final String visaPrice;

  const VisaCountryModel({
    required this.id,
    required this.name,
    required this.visaPrice,
  });

  String get displayName => Utils.parseLocalizedName(name);

  factory VisaCountryModel.fromJson(Map<String, dynamic> json) =>
      VisaCountryModel(
        id: json["id"],
        name: json["name"] is Map
            ? Map<String, dynamic>.from(json["name"])
            : {},
        visaPrice: json["visa_price"]?.toString() ?? "0.00",
      );
}
