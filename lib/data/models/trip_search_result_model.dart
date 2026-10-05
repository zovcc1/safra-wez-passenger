import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/presentation/util/utils.dart';

enum TripSearchResultType { trip, openTrip }

class TripSearchRouteModel {
  final int routeId;
  final Map<String, dynamic> name;

  const TripSearchRouteModel({required this.routeId, required this.name});

  String get displayName =>
      Utils.fixRouteArrows(Utils.parseLocalizedName(name));

  factory TripSearchRouteModel.fromJson(Map<String, dynamic> json) =>
      TripSearchRouteModel(
        routeId: json["route_id"],
        name: json["name"] is Map
            ? Map<String, dynamic>.from(json["name"])
            : {},
      );
}

class TripSearchVehicleModel {
  final int vehicleId;
  final String vehicleType;
  final int capacity;

  const TripSearchVehicleModel({
    required this.vehicleId,
    required this.vehicleType,
    required this.capacity,
  });

  factory TripSearchVehicleModel.fromJson(Map<String, dynamic> json) =>
      TripSearchVehicleModel(
        vehicleId: json["vehicle_id"],
        vehicleType: json["vehicle_type"] ?? "",
        capacity: json["capacity"] ?? 0,
      );
}

/// عنصر موحّد لنتيجة البحث — يمثّل مقعدًا متاحًا واحدًا إمّا برحلة مجدولة
/// (result_type=trip، له departure_time) أو رحلة مفتوحة (result_type=open_trip،
/// لها expires_at بدل موعد انطلاق ثابت).
class TripSearchResultModel {
  final TripSearchResultType resultType;
  final int id;
  final TripSearchRouteModel route;
  final int providerId;
  final TripSearchVehicleModel vehicle;
  final int availableSeats;
  final String basePrice;
  final DateTime? departureTime;
  final DateTime? expiresAt;

  /// TR1: نوع الجلب ونقاطه. fixed_point = السلوك القديم بلا أي حقل إضافي.
  final PickupMode pickupMode;
  final GeoPointModel? startPoint;
  final GeoPointModel? endPoint;
  final bool allowRoutePickup;
  final List<CollectionPointModel> collectionPoints;

  /// ratingsCount هو العدد المنشور لا الفعلي. إذا ratingIsDefault=true فالمزوّد
  /// ما نُشر له تقييم بعد، وavgRating مجرد قيمة افتراضية → "مزوّد جديد".
  final double avgRating;
  final int ratingsCount;
  final bool ratingIsDefault;

  const TripSearchResultModel({
    required this.resultType,
    required this.id,
    required this.route,
    required this.providerId,
    required this.vehicle,
    required this.availableSeats,
    required this.basePrice,
    this.departureTime,
    this.expiresAt,
    this.pickupMode = PickupMode.fixedPoint,
    this.startPoint,
    this.endPoint,
    this.allowRoutePickup = false,
    this.collectionPoints = const [],
    this.avgRating = 0,
    this.ratingsCount = 0,
    this.ratingIsDefault = true,
  });

  bool get isOpenTrip => resultType == TripSearchResultType.openTrip;

  factory TripSearchResultModel.fromJson(Map<String, dynamic> json) {
    final isOpenTrip = json["result_type"] == "open_trip";
    return TripSearchResultModel(
      resultType: isOpenTrip
          ? TripSearchResultType.openTrip
          : TripSearchResultType.trip,
      id: (isOpenTrip ? json["open_trip_id"] : json["trip_id"]) ?? 0,
      route: TripSearchRouteModel.fromJson(
        Map<String, dynamic>.from(json["route"] ?? {}),
      ),
      providerId: json["provider_id"] ?? 0,
      vehicle: TripSearchVehicleModel.fromJson(
        Map<String, dynamic>.from(json["vehicle"] ?? {}),
      ),
      availableSeats: json["available_seats"] ?? 0,
      basePrice: json["base_price"]?.toString() ?? "0",
      departureTime: json["departure_time"] != null
          ? DateTime.tryParse(json["departure_time"])
          : null,
      expiresAt: json["expires_at"] != null
          ? DateTime.tryParse(json["expires_at"])
          : null,
      avgRating: double.tryParse(json["avg_rating"]?.toString() ?? "") ?? 0,
      ratingsCount: json["ratings_count"] ?? 0,
      ratingIsDefault: json["rating_is_default"] ?? true,
      pickupMode: PickupMode.parse(json["pickup_mode"]),
      startPoint: GeoPointModel.tryParse(json["start_point"]),
      endPoint: GeoPointModel.tryParse(json["end_point"]),
      allowRoutePickup: json["allow_route_pickup"] ?? false,
      collectionPoints:
          List<Map<String, dynamic>>.from(
              (json["collection_points"] as List? ?? const []).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            ).map(CollectionPointModel.fromJson).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    );
  }
}
