import 'package:safraa_passenger_app/presentation/util/utils.dart';

class GovernorateModel {
  final int governorateId;
  final Map<String, dynamic> name;

  const GovernorateModel({required this.governorateId, required this.name});

  String get displayName => Utils.parseLocalizedName(name);

  factory GovernorateModel.fromJson(Map<String, dynamic> json) =>
      GovernorateModel(
        governorateId: json["governorate_id"],
        name: json["name"] is Map
            ? Map<String, dynamic>.from(json["name"])
            : {},
      );
}
