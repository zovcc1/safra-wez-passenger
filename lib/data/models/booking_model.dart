import 'package:safraa_passenger_app/data/models/booking_rating_model.dart';
import 'package:safraa_passenger_app/data/models/governorate_model.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/presentation/util/utils.dart';

class BookingSeatModel {
  final int tripSeatId;
  final String seatNumber;

  const BookingSeatModel({required this.tripSeatId, required this.seatNumber});

  factory BookingSeatModel.fromJson(Map<String, dynamic> json) =>
      BookingSeatModel(
        tripSeatId: json["trip_seat_id"] ?? 0,
        seatNumber: json["seat_number"]?.toString() ?? "",
      );
}

// First-strong / pop isolates keep mixed-language names from reordering.
final _fsi = String.fromCharCode(0x2068);
final _pdi = String.fromCharCode(0x2069);

class BookingRouteModel {
  final int routeId;
  final GovernorateModel? origin;
  final GovernorateModel? destination;

  const BookingRouteModel({
    required this.routeId,
    this.origin,
    this.destination,
  });

  String get displayName => origin == null || destination == null
      ? ""
      : "$_fsi${origin!.displayName}$_pdi ${Utils.routeArrow} $_fsi${destination!.displayName}$_pdi";

  factory BookingRouteModel.fromJson(Map<String, dynamic> json) =>
      BookingRouteModel(
        routeId: json["route_id"] ?? 0,
        origin: json["origin"] is Map
            ? GovernorateModel.fromJson(
                Map<String, dynamic>.from(json["origin"]),
              )
            : null,
        destination: json["destination"] is Map
            ? GovernorateModel.fromJson(
                Map<String, dynamic>.from(json["destination"]),
              )
            : null,
      );
}

/// حالة "الرحلة" المرتبطة بالحجز، وليست حالة الحجز نفسه (راجع BookingModel.status).
class BookingJourneyModel {
  final String type;
  final DateTime? departureTime;
  final DateTime? expiresAt;
  final String status;
  final String basePrice;
  final BookingRouteModel? route;

  const BookingJourneyModel({
    required this.type,
    this.departureTime,
    this.expiresAt,
    required this.status,
    required this.basePrice,
    this.route,
  });

  bool get isOpenTrip => type == "open_trip";

  factory BookingJourneyModel.fromJson(Map<String, dynamic> json) =>
      BookingJourneyModel(
        type: json["type"] ?? "trip",
        departureTime: json["departure_time"] != null
            ? DateTime.tryParse(json["departure_time"])
            : null,
        expiresAt: json["expires_at"] != null
            ? DateTime.tryParse(json["expires_at"])
            : null,
        status: json["status"] ?? "",
        basePrice: json["base_price"]?.toString() ?? "0",
        route: json["route"] is Map
            ? BookingRouteModel.fromJson(
                Map<String, dynamic>.from(json["route"]),
              )
            : null,
      );
}

/// عنصر حجز واحد — نفس الشكل يُستخدم في القائمة (9.2) والتفاصيل (9.3) وردّ
/// الإنشاء (9.1). ملاحظة مهمة من المواصفات: promotion_outcome=assigned لا
/// يعني "مؤكَّد" — الحالة الفعلية تُقرأ دومًا من status.
class BookingModel {
  final int bookingId;
  final int? tripId;
  final int? openTripId;
  final int seatsCount;
  final String status;
  final String paymentMethod;
  final String totalAmount;
  final String currency;
  final String? bookingToken;
  final DateTime? confirmedAt;
  final DateTime? boardedAt;
  final DateTime? noShowAt;
  final String? promotionOutcome;
  final bool transferredByHandoff;
  final bool seatAssignmentSplit;
  final DateTime? createdAt;
  final BookingJourneyModel? journey;
  final List<BookingSeatModel> seats;

  /// نقطة الركوب؛ null بحجز fixed_point.
  final BookingPickupModel? pickup;

  /// يُؤخذ من الـ API فقط ولا يُحسب من جهة التطبيق أبدًا (مدة التقييم وحالة
  /// الرحلة قواعد خادم).
  final bool canRate;
  final BookingRatingModel? rating;

  const BookingModel({
    required this.bookingId,
    this.tripId,
    this.openTripId,
    required this.seatsCount,
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.currency,
    this.bookingToken,
    this.confirmedAt,
    this.boardedAt,
    this.noShowAt,
    this.promotionOutcome,
    required this.transferredByHandoff,
    required this.seatAssignmentSplit,
    this.createdAt,
    this.journey,
    required this.seats,
    this.pickup,
    this.canRate = false,
    this.rating,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    bookingId: json["booking_id"] ?? 0,
    tripId: json["trip_id"],
    openTripId: json["open_trip_id"],
    seatsCount: json["seats_count"] ?? 0,
    status: json["status"] ?? "",
    paymentMethod: json["payment_method"] ?? "",
    totalAmount: json["total_amount"]?.toString() ?? "0",
    currency: json["currency"] ?? "SYP",
    bookingToken: json["booking_token"],
    confirmedAt: json["confirmed_at"] != null
        ? DateTime.tryParse(json["confirmed_at"])
        : null,
    boardedAt: json["boarded_at"] != null
        ? DateTime.tryParse(json["boarded_at"])
        : null,
    noShowAt: json["no_show_at"] != null
        ? DateTime.tryParse(json["no_show_at"])
        : null,
    promotionOutcome: json["promotion_outcome"],
    transferredByHandoff: json["transferred_by_handoff"] ?? false,
    seatAssignmentSplit: json["seat_assignment_split"] ?? false,
    createdAt: json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : null,
    journey: json["journey"] is Map
        ? BookingJourneyModel.fromJson(
            Map<String, dynamic>.from(json["journey"]),
          )
        : null,
    seats: List<Map<String, dynamic>>.from(
      json["seats"] ?? const [],
    ).map(BookingSeatModel.fromJson).toList(),
    pickup: json["pickup"] is Map
        ? BookingPickupModel.fromJson(Map<String, dynamic>.from(json["pickup"]))
        : null,
    canRate: json["can_rate"] ?? false,
    rating: json["rating"] is Map
        ? BookingRatingModel.fromJson(Map<String, dynamic>.from(json["rating"]))
        : null,
  );
}
