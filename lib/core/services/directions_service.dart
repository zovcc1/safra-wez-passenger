import 'dart:io' show Platform;

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
      // Routes API (بديل Directions القديم غير المفعّل). المفتاح مقيَّد بتطبيق
      // Android/iOS فلازم إرسال هوية التطبيق في الترويسات.
      final response = await _dio.post(
        "https://routes.googleapis.com/directions/v2:computeRoutes",
        options: Options(
          headers: {
            "X-Goog-Api-Key": Env.googleDirectionsKey,
            "X-Goog-FieldMask":
                "routes.duration,routes.distanceMeters,routes.description,"
                "routes.polyline.encodedPolyline",
            if (Platform.isAndroid) ...{
              "X-Android-Package": Env.androidPackage,
              "X-Android-Cert": Env.androidCertSha1,
            },
            if (Platform.isIOS) "X-Ios-Bundle-Identifier": Env.iosBundleId,
          },
        ),
        data: {
          "origin": _waypoint(origin),
          "destination": _waypoint(destination),
          "travelMode": "DRIVE",
          "routingPreference": "TRAFFIC_AWARE",
          "polylineQuality": "HIGH_QUALITY",
          "computeAlternativeRoutes": true,
          "languageCode": AppTranslations.currentLang,
        },
      );
      final routes = (response.data as Map)["routes"] as List? ?? const [];
      return routes.map((r) {
        r as Map;
        return RouteOption(
          points: decodePolyline(r["polyline"]["encodedPolyline"] as String),
          distanceMeters: (r["distanceMeters"] as num?)?.toInt() ?? 0,
          durationSeconds:
              int.tryParse("${r["duration"]}".replaceAll("s", "")) ?? 0,
          summary: r["description"]?.toString() ?? "",
        );
      }).toList();
    } on DioException catch (e) {
      debugPrint("Routes failed: ${e.response?.data ?? e.message}");
      return const [];
    } catch (e) {
      debugPrint("Routes failed: $e");
      return const [];
    }
  }

  static Map<String, dynamic> _waypoint(LatLng p) => {
    "location": {
      "latLng": {"latitude": p.latitude, "longitude": p.longitude},
    },
  };

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
