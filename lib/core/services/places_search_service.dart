import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safraa_passenger_app/core/config/env.dart';

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

/// بحث أماكن بالاسم عبر OpenStreetMap (Nominatim) بلا مفتاح. العنونة العكسية
/// تجرّب Google Geocoding أولًا (يلزم تفعيله على المفتاح) ثم تعود لـ OSM.
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
    final google = await _searchGoogle(query, bias, language);
    if (google.isNotEmpty) return google;
    return _searchOsm(query, bias: bias, language: language);
  }

  /// هوية التطبيق التي يشترطها مفتاح Google المقيَّد بتطبيق Android/iOS.
  Options get _googleOptions => Options(
    headers: {
      if (Platform.isAndroid) ...{
        "X-Android-Package": Env.androidPackage,
        "X-Android-Cert": Env.androidCertSha1,
      },
      if (Platform.isIOS) "X-Ios-Bundle-Identifier": Env.iosBundleId,
    },
  );

  /// بحث Google Geocoding: أدق من OSM بالعناوين والمعالم، مع تفضيل (لا حصر)
  /// المنطقة حول مركز الخريطة عبر bounds.
  Future<List<PlaceSuggestion>> _searchGoogle(
    String query,
    LatLng bias,
    String language,
  ) async {
    if (Env.googleDirectionsKey.isEmpty) return const [];
    try {
      final res = await _dio.get(
        "https://maps.googleapis.com/maps/api/geocode/json",
        queryParameters: {
          "address": query,
          "language": language,
          "bounds":
              "${bias.latitude - 0.5},${bias.longitude - 0.5}|"
              "${bias.latitude + 0.5},${bias.longitude + 0.5}",
          "key": Env.googleDirectionsKey,
        },
        options: _googleOptions,
      );
      final status = res.data["status"];
      if (status != "OK") {
        if (status != "ZERO_RESULTS") {
          debugPrint("Geocode search failed: $status");
        }
        return const [];
      }
      final results = (res.data["results"] as List?) ?? const [];
      return results.cast<Map>().take(8).map<PlaceSuggestion>((r) {
        final comps = (r["address_components"] as List?) ?? const [];
        final first = comps.isEmpty
            ? ""
            : ((comps.first as Map)["long_name"]?.toString() ?? "");
        var formatted = (r["formatted_address"]?.toString() ?? "").trim();
        final title = first.isNotEmpty
            ? first
            : formatted.split(RegExp(r"[،,]")).first.trim();
        if (formatted.startsWith(title)) {
          formatted = formatted
              .substring(title.length)
              .replaceFirst(RegExp(r"^\s*[،,]\s*"), "")
              .trim();
        }
        final loc = r["geometry"]["location"] as Map;
        return PlaceSuggestion(
          title: title,
          subtitle: formatted,
          position: LatLng(
            (loc["lat"] as num).toDouble(),
            (loc["lng"] as num).toDouble(),
          ),
        );
      }).toList();
    } catch (e) {
      debugPrint("Geocode search error: $e");
      return const [];
    }
  }

  Future<List<PlaceSuggestion>> _searchOsm(
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

  /// اسم ومنطقة إحداثية، أو null عند الفشل. الاسم: المعلم/المبنى إن وُجد ثم
  /// الشارع (مع رقم المبنى) ثم الحي. المنطقة: الحي، المدينة، المحافظة بترتيب
  /// من الأدق إلى الأعم بلا تكرار.
  Future<({String title, String region})?> reverse(
    LatLng position, {
    required String language,
  }) async {
    // Google Geocoding أدق بكثير (خصوصًا في سوريا)، وOSM احتياطي عند فشله.
    return await _reverseGoogle(position, language) ??
        await _reverseOsm(position, language);
  }

  Future<({String title, String region})?> _reverseGoogle(
    LatLng position,
    String language,
  ) async {
    if (Env.googleDirectionsKey.isEmpty) return null;
    try {
      // المفتاح مقيَّد بتطبيق Android/iOS فلازم إرسال هوية التطبيق.
      final res = await _dio.get(
        "https://maps.googleapis.com/maps/api/geocode/json",
        queryParameters: {
          "latlng": "${position.latitude},${position.longitude}",
          "language": language,
          "key": Env.googleDirectionsKey,
        },
        options: _googleOptions,
      );
      if (res.data["status"] != "OK") {
        debugPrint("Geocode failed: ${res.data["status"]} "
            "${res.data["error_message"] ?? ""}");
        return null;
      }
      final results = (res.data["results"] as List?) ?? const [];
      // أول نتيجة ليست Plus Code، وهي الأدق (عنوان/مبنى/شارع).
      final best = results.cast<Map>().firstWhere(
        (r) => !((r["types"] as List?) ?? const []).contains("plus_code"),
        orElse: () => const {},
      );
      final comps = (best["address_components"] as List?) ?? const [];
      String? comp(List<String> types, {bool short = false}) {
        for (final c in comps.cast<Map>()) {
          final t = (c["types"] as List?) ?? const [];
          if (types.any(t.contains)) {
            final v = c[short ? "short_name" : "long_name"]?.toString().trim();
            if (v != null && v.isNotEmpty) return v;
          }
        }
        return null;
      }

      final poi = comp(["point_of_interest", "establishment", "premise"]);
      final route = comp(["route"]);
      final number = comp(["street_number"]);
      final area = comp([
        "sublocality_level_1",
        "sublocality",
        "neighborhood",
      ]);
      final city = comp(["locality", "administrative_area_level_3"]);
      final county = comp(["administrative_area_level_2"]);
      final state = comp(["administrative_area_level_1"]);

      var title =
          poi ?? [route, number].whereType<String>().join(" ").trim();
      if (title.isEmpty) title = area ?? city ?? "";
      if (title.isEmpty) return null;
      // التفاصيل الكاملة: العنوان المنسّق من Google (بدون Plus Code ولا تكرار
      // الاسم)، وإن غاب فالمكوّنات مرتبة من الأدق إلى الأعم.
      var formatted = (best["formatted_address"]?.toString() ?? "").trim();
      formatted = formatted
          .replaceFirst(RegExp(r"^[A-Z0-9]{4,}\+[A-Z0-9]{2,}[^،,]*[،,]?\s*"), "")
          .trim();
      if (formatted.startsWith(title)) {
        formatted = formatted
            .substring(title.length)
            .replaceFirst(RegExp(r"^\s*[،,]\s*"), "")
            .trim();
      }
      final region = formatted.isNotEmpty
          ? formatted
          : <String>{
              ?area,
              ?city,
              ?county,
              ?state,
            }.where((e) => e != title).join("، ");
      return (title: title, region: region);
    } catch (e) {
      debugPrint("Geocode error: $e");
      return null;
    }
  }

  Future<({String title, String region})?> _reverseOsm(
    LatLng position,
    String language,
  ) async {
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
      String? pick(List<String> keys) {
        for (final k in keys) {
          final v = a[k]?.toString().trim();
          if (v != null && v.isNotEmpty) return v;
        }
        return null;
      }

      final name = res.data["name"]?.toString().trim();
      final road = pick(["road", "pedestrian", "residential"]);
      final house = a["house_number"]?.toString().trim();
      final area = pick(["suburb", "neighbourhood", "quarter", "city_district"]);
      final city = pick(["city", "town", "village", "municipality"]);
      final county = pick(["county", "state_district"]);
      final state = pick(["state", "province"]);

      var title = (name != null && name.isNotEmpty)
          ? name
          : [road, house].whereType<String>().join(" ");
      if (title.isEmpty) title = area ?? city ?? "";
      if (title.isEmpty) return null;

      final region = <String>{
        ?area,
        ?city,
        ?county,
        ?state,
      }.where((e) => e != title).join("، ");
      return (title: title, region: region);
    } catch (_) {
      return null;
    }
  }
}
