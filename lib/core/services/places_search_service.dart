import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion {
  /// الاسم الرئيسي (مبنى/شارع/حي).
  final String title;

  /// التفاصيل (الحي، المدينة، المحافظة…).
  final String subtitle;

  final LatLng position;

  const PlaceSuggestion({
    required this.title,
    required this.subtitle,
    required this.position,
  });

  String get fullLabel => subtitle.isEmpty ? title : "$title، $subtitle";
}

/// بحث أماكن بالاسم وعنونة عكسية عبر OpenStreetMap (Nominatim) بلا مفتاح.
/// (مفتاح Google في التطبيق مقيَّد بـ Directions فقط.)
class PlacesSearchService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"User-Agent": "safraa_passenger_app"},
    ),
  );

  /// [bias]: مركز الخريطة الحالي لتفضيل النتائج القريبة منه.
  Future<List<PlaceSuggestion>> search(
    String query, {
    required LatLng bias,
    required String language,
  }) async {
    try {
      final res = await _dio.get(
        "https://nominatim.openstreetmap.org/search",
        queryParameters: {
          "q": query,
          "format": "jsonv2",
          "addressdetails": 1,
          "limit": 8,
          "accept-language": language,
          "viewbox":
              "${bias.longitude - 0.5},${bias.latitude + 0.5},${bias.longitude + 0.5},${bias.latitude - 0.5}",
        },
      );
      final list = (res.data as List?) ?? const [];
      return list.map<PlaceSuggestion>((e) {
        final a = (e["address"] as Map?) ?? const {};
        final title = e["name"]?.toString().isNotEmpty == true
            ? e["name"].toString()
            : [a["road"], a["house_number"]].whereType<String>().join(" ");
        final subtitle = [
          a["suburb"] ?? a["neighbourhood"] ?? a["quarter"],
          a["city"] ?? a["town"] ?? a["village"],
          a["state"],
        ].whereType<String>().toSet().join("، ");
        return PlaceSuggestion(
          title: title.isEmpty
              ? (e["display_name"]?.toString().split(",").first ?? "")
              : title,
          subtitle: subtitle,
          position: LatLng(
            double.parse(e["lat"].toString()),
            double.parse(e["lon"].toString()),
          ),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  /// عنوان نصي لإحداثية، أو null عند الفشل.
  Future<String?> reverse(LatLng position, {required String language}) async {
    try {
      final res = await _dio.get(
        "https://nominatim.openstreetmap.org/reverse",
        queryParameters: {
          "lat": position.latitude,
          "lon": position.longitude,
          "format": "jsonv2",
          "zoom": 18,
          "addressdetails": 1,
          "accept-language": language,
        },
      );
      final a = (res.data["address"] as Map?) ?? const {};
      final parts = <String>{
        ...[
          a["road"],
          a["suburb"] ?? a["neighbourhood"] ?? a["quarter"],
          a["city"] ?? a["town"] ?? a["village"],
        ].whereType<String>(),
      };
      return parts.isEmpty ? null : parts.join("، ");
    } catch (_) {
      return null;
    }
  }
}
