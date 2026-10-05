import 'package:safraa_passenger_app/data/dto/pickup_dto.dart';

/// راجع القسم 9.1: رحلة مجدولة تُرسل tripId + tripSeatIds، ورحلة مفتوحة
/// تُرسل openTripId + seatsCount — الحقلان الآخران يُتركان null بكل حالة.
/// pickup إلزامي على رحلات collection_points/door_to_door، ويُتجاهل على
/// fixed_point والرحلات المفتوحة.
class CreateBookingDto {
  final int? tripId;
  final List<int>? tripSeatIds;
  final int? openTripId;
  final int? seatsCount;
  final String paymentMethod;
  final String idempotencyKey;
  final PickupDto? pickup;

  const CreateBookingDto.scheduledTrip({
    required this.tripId,
    required this.tripSeatIds,
    required this.paymentMethod,
    required this.idempotencyKey,
    this.pickup,
  }) : openTripId = null,
       seatsCount = null;

  const CreateBookingDto.openTrip({
    required this.openTripId,
    required this.seatsCount,
    required this.paymentMethod,
    required this.idempotencyKey,
  }) : tripId = null,
       tripSeatIds = null,
       pickup = null;

  Map<String, dynamic> toJson() => {
    if (tripId != null) "trip_id": tripId,
    if (tripSeatIds != null) "trip_seat_ids": tripSeatIds,
    if (openTripId != null) "open_trip_id": openTripId,
    if (seatsCount != null) "seats_count": seatsCount,
    "payment_method": paymentMethod,
    "idempotency_key": idempotencyKey,
    if (pickup != null) "pickup": pickup!.toJson(),
  };
}
