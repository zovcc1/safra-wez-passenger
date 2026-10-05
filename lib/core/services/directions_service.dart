import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/core/config/env.dart';

class RouteOption {
  final List<LatLng> points;
  final int distanceMeters;
  final int durationSeconds;
  final String summary;

  const RouteOption({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.summary,
  });
}

/// مسارات الطرق بين نقطتين عبر Google Directions (مع البدائل). يرجّع قائمة
/// فارغة عند غياب المفتاح أو فشل الطلب، ويتصرف المستهلك بخط مستقيم احتياطي.
abstract class DirectionsService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static bool get isConfigured => Env.googleDirectionsKey.isNotEmpty;

  static Future<List<RouteOption>> fetch(
    LatLng origin,
    LatLng destination,
  ) async {
    if (!isConfigured) return const [];
    try {
      final response = await _dio.get(
        "https://maps.googleapis.com/maps/api/directions/json",
        queryParameters: {
          "origin": "${origin.latitude},${origin.longitude}",
          "destination": "${destination.latitude},${destination.longitude}",
          "alternatives": "true",
          "language": AppTranslations.currentLang,
          "key": Env.googleDirectionsKey,
        },
      );
      final data = response.data as Map;
      if (data["status"] != "OK") {
        debugPrint(
          "Directions status: ${data["status"]} ${data["error_message"] ?? ""}",
        );
        return const [];
      }
      return (data["routes"] as List).map((r) {
        final leg = (r["legs"] as List).first as Map;
        return RouteOption(
          points: decodePolyline(r["overview_polyline"]["points"] as String),
          distanceMeters: (leg["distance"]["value"] as num).toInt(),
          durationSeconds: (leg["duration"]["value"] as num).toInt(),
          summary: r["summary"]?.toString() ?? "",
        );
      }).toList();
    } catch (e) {
      debugPrint("Directions failed: $e");
      return const [];
    }
  }

  /// Google encoded polyline algorithm.
  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      for (final isLat in [true, false]) {
        var result = 0, shift = 0;
        int b;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        final delta = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
        if (isLat) {
          lat += delta;
        } else {
          lng += delta;
        }
      }
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
