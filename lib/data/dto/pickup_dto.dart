/// كتلة pickup في POST /passenger/bookings و PATCH .../pickup-point.
class PickupDto {
  /// collection_point | gps | pin
  final String source;
  final int? collectionPointId;
  final double? latitude;
  final double? longitude;
  final String? address;

  const PickupDto.collectionPoint(int id)
    : source = "collection_point",
      collectionPointId = id,
      latitude = null,
      longitude = null,
      address = null;

  const PickupDto.location({
    required this.source,
    required double this.latitude,
    required double this.longitude,
    this.address,
  }) : collectionPointId = null;

  Map<String, dynamic> toJson() => {
    "source": source,
    if (collectionPointId != null) "collection_point_id": collectionPointId,
    if (latitude != null) "latitude": latitude,
    if (longitude != null) "longitude": longitude,
    if (address != null && address!.trim().isNotEmpty)
      "address": address!.trim(),
  };
}
