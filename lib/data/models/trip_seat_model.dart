enum TripSeatStatus { available, booked, blocked }

TripSeatStatus _parseSeatStatus(String? value) {
  switch (value) {
    case "booked":
      return TripSeatStatus.booked;
    case "blocked":
      return TripSeatStatus.blocked;
    default:
      return TripSeatStatus.available;
  }
}

/// عنصر مقعد فردي لرحلة مجدولة — GET /passenger/trips/{trip}/seats، راوت
/// عام بلا توكن. لازم لبناء trip_seat_ids عند إنشاء حجز على رحلة مجدولة
/// (راجع القسم 9.1). seat_number نصّ تسلسلي "1".."N" وليس إحداثيًّا في شبكة.
class TripSeatModel {
  final int tripSeatId;
  final int tripId;
  final String seatNumber;
  final TripSeatStatus status;
  final int version;

  const TripSeatModel({
    required this.tripSeatId,
    required this.tripId,
    required this.seatNumber,
    required this.status,
    required this.version,
  });

  bool get isAvailable => status == TripSeatStatus.available;

  factory TripSeatModel.fromJson(Map<String, dynamic> json) => TripSeatModel(
    tripSeatId: json["trip_seat_id"] ?? 0,
    tripId: json["trip_id"] ?? 0,
    seatNumber: json["seat_number"]?.toString() ?? "",
    status: _parseSeatStatus(json["status"]),
    version: json["version"] ?? 0,
  );
}
