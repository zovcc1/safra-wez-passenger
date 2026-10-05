enum PickupMode {
  fixedPoint,
  collectionPoints,
  doorToDoor;

  static PickupMode parse(dynamic value) => switch (value) {
    "collection_points" => PickupMode.collectionPoints,
    "door_to_door" => PickupMode.doorToDoor,
    _ => PickupMode.fixedPoint,
  };
}

/// REST يرجّع الإحداثيات كنصوص بـ 7 خانات، بينما الـ socket و position أرقام.
double? parseCoordinate(dynamic value) =>
    value == null ? null : double.tryParse(value.toString());

class GeoPointModel {
  final double latitude;
  final double longitude;
  final String? address;

  const GeoPointModel({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  static GeoPointModel? tryParse(dynamic json) {
    if (json is! Map) return null;
    final lat = parseCoordinate(json["latitude"]);
    final lng = parseCoordinate(json["longitude"]);
    if (lat == null || lng == null) return null;
    return GeoPointModel(
      latitude: lat,
      longitude: lng,
      address: json["address"]?.toString(),
    );
  }
}

class CollectionPointModel {
  final int collectionPointId;
  final String name;
  final double latitude;
  final double longitude;
  final int sortOrder;

  const CollectionPointModel({
    required this.collectionPointId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sortOrder,
  });

  factory CollectionPointModel.fromJson(Map<String, dynamic> json) =>
      CollectionPointModel(
        collectionPointId: json["collection_point_id"] ?? 0,
        name: json["name"]?.toString() ?? "",
        latitude: parseCoordinate(json["latitude"]) ?? 0,
        longitude: parseCoordinate(json["longitude"]) ?? 0,
        sortOrder: json["sort_order"] ?? 0,
      );
}

/// نقطة ركوب الحجز (كتلة pickup). null بحجز fixed_point.
class BookingPickupModel {
  /// gps | pin | collection_point
  final String source;
  final int? collectionPointId;
  final bool locationVisible;
  final String? address;
  final double? latitude;
  final double? longitude;

  /// true = مُسحت الإحداثيات بعد 30 يومًا من نهاية الرحلة (يبقى العنوان).
  final bool coordinatesRedacted;

  const BookingPickupModel({
    required this.source,
    this.collectionPointId,
    required this.locationVisible,
    this.address,
    this.latitude,
    this.longitude,
    required this.coordinatesRedacted,
  });

  bool get hasCoordinates =>
      !coordinatesRedacted && latitude != null && longitude != null;

  bool get isCollectionPoint => source == "collection_point";

  factory BookingPickupModel.fromJson(Map<String, dynamic> json) =>
      BookingPickupModel(
        source: json["source"]?.toString() ?? "",
        collectionPointId: json["collection_point_id"],
        locationVisible: json["location_visible"] ?? false,
        address: json["address"]?.toString(),
        latitude: parseCoordinate(json["latitude"]),
        longitude: parseCoordinate(json["longitude"]),
        coordinatesRedacted: json["coordinates_redacted"] ?? false,
      );
}

class TrackingPositionModel {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final DateTime? recordedAt;

  const TrackingPositionModel({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    this.recordedAt,
  });

  /// يخدم لقطة REST (أرقام) وحدث الـ socket (أرقام) معًا.
  static TrackingPositionModel? tryParse(dynamic json) {
    if (json is! Map) return null;
    final lat = parseCoordinate(json["latitude"]);
    final lng = parseCoordinate(json["longitude"]);
    if (lat == null || lng == null) return null;
    return TrackingPositionModel(
      latitude: lat,
      longitude: lng,
      heading: parseCoordinate(json["heading"]),
      speed: parseCoordinate(json["speed"]),
      accuracy: parseCoordinate(json["accuracy"]),
      recordedAt: json["recorded_at"] != null
          ? DateTime.tryParse(json["recorded_at"].toString())
          : null,
    );
  }
}

class TrackingSnapshotModel {
  final int bookingId;
  final String bookingStatus;
  final int tripId;
  final String tripStatus;
  final PickupMode pickupMode;

  /// null | not_started | in_progress | completed
  final String? pickupPhase;
  final TrackingPositionModel? position;
  final int? etaMinutes;
  final DateTime? etaComputedAt;
  final int? stopSequence;
  final DateTime? stopArrivedAt;

  const TrackingSnapshotModel({
    required this.bookingId,
    required this.bookingStatus,
    required this.tripId,
    required this.tripStatus,
    required this.pickupMode,
    this.pickupPhase,
    this.position,
    this.etaMinutes,
    this.etaComputedAt,
    this.stopSequence,
    this.stopArrivedAt,
  });

  factory TrackingSnapshotModel.fromJson(Map<String, dynamic> json) {
    final stop = json["stop"] is Map ? json["stop"] as Map : null;
    return TrackingSnapshotModel(
      bookingId: json["booking_id"] ?? 0,
      bookingStatus: json["booking_status"]?.toString() ?? "",
      tripId: json["trip_id"] ?? 0,
      tripStatus: json["trip_status"]?.toString() ?? "",
      pickupMode: PickupMode.parse(json["pickup_mode"]),
      pickupPhase: json["pickup_phase"]?.toString(),
      position: TrackingPositionModel.tryParse(json["position"]),
      etaMinutes: json["eta_minutes"],
      etaComputedAt: json["eta_computed_at"] != null
          ? DateTime.tryParse(json["eta_computed_at"].toString())
          : null,
      stopSequence: stop?["sequence"],
      stopArrivedAt: stop?["arrived_at"] != null
          ? DateTime.tryParse(stop!["arrived_at"].toString())
          : null,
    );
  }
}
