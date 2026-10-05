import 'package:safraa_passenger_app/data/models/booking_model.dart';

class PaymentRequestTargetModel {
  /// trip | open_trip
  final String type;
  final int id;
  final DateTime? departureTime;
  final DateTime? expiresAt;
  final BookingRouteModel? route;

  const PaymentRequestTargetModel({
    required this.type,
    required this.id,
    this.departureTime,
    this.expiresAt,
    this.route,
  });

  bool get isOpenTrip => type == "open_trip";

  factory PaymentRequestTargetModel.fromJson(Map<String, dynamic> json) =>
      PaymentRequestTargetModel(
        type: json["type"]?.toString() ?? "trip",
        id: json["id"] ?? 0,
        departureTime: json["departure_time"] != null
            ? DateTime.tryParse(json["departure_time"].toString())
            : null,
        expiresAt: json["expires_at"] != null
            ? DateTime.tryParse(json["expires_at"].toString())
            : null,
        route: json["route"] is Map
            ? BookingRouteModel.fromJson(
                Map<String, dynamic>.from(json["route"]),
              )
            : null,
      );
}

class PaymentRequestModel {
  final int paymentRequestId;

  /// pending | approved | rejected | expired | cancelled
  final String status;
  final String? terminalReason;
  final DateTime? expiresAt;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final int bookingId;

  /// نص من الخادم، لا يُحوَّل إلى float.
  final String amount;
  final String currency;
  final int seatsCount;
  final List<BookingSeatModel> seats;
  final PaymentRequestTargetModel? target;

  const PaymentRequestModel({
    required this.paymentRequestId,
    required this.status,
    this.terminalReason,
    this.expiresAt,
    this.resolvedAt,
    this.createdAt,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.seatsCount,
    required this.seats,
    this.target,
  });

  bool get isPending => status == "pending";

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) =>
      PaymentRequestModel(
        paymentRequestId: json["payment_request_id"] ?? 0,
        status: json["status"]?.toString() ?? "",
        terminalReason: json["terminal_reason"]?.toString(),
        expiresAt: json["expires_at"] != null
            ? DateTime.tryParse(json["expires_at"].toString())
            : null,
        resolvedAt: json["resolved_at"] != null
            ? DateTime.tryParse(json["resolved_at"].toString())
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"].toString())
            : null,
        bookingId: json["booking_id"] ?? 0,
        amount: json["amount"]?.toString() ?? "0",
        currency: json["currency"]?.toString() ?? "SYP",
        seatsCount: json["seats_count"] ?? 0,
        seats: List<Map<String, dynamic>>.from(
          (json["seats"] as List? ?? const []).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        ).map(BookingSeatModel.fromJson).toList(),
        target: json["target"] is Map
            ? PaymentRequestTargetModel.fromJson(
                Map<String, dynamic>.from(json["target"]),
              )
            : null,
      );
}
