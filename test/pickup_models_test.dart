import 'package:flutter_test/flutter_test.dart';
import 'package:safraa_passenger_app/data/dto/create_booking_dto.dart';
import 'package:safraa_passenger_app/data/dto/pickup_dto.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/data/models/notification_models.dart';
import 'package:safraa_passenger_app/data/models/payment_request_model.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/data/models/trip_search_result_model.dart';

void main() {
  test('search: collection_points trip parses points sorted', () {
    final m = TripSearchResultModel.fromJson({
      "result_type": "trip",
      "trip_id": 1,
      "pickup_mode": "collection_points",
      "start_point": {
        "latitude": "33.5138000",
        "longitude": "36.2765000",
        "address": "Umayyad Square",
      },
      "end_point": null,
      "allow_route_pickup": false,
      "collection_points": [
        {
          "collection_point_id": 2,
          "name": "Baramkeh garage",
          "latitude": "33.5000000",
          "longitude": "36.3000000",
          "sort_order": 1,
        },
        {
          "collection_point_id": 1,
          "name": "Mezzeh roundabout",
          "latitude": "33.5200000",
          "longitude": "36.2900000",
          "sort_order": 0,
        },
      ],
      "route": {"route_id": 1, "name": {}},
      "vehicle": {"vehicle_id": 1, "vehicle_type": "van", "capacity": 10},
    });
    expect(m.pickupMode, PickupMode.collectionPoints);
    expect(m.startPoint!.latitude, 33.5138);
    expect(m.endPoint, isNull);
    expect(m.collectionPoints.first.collectionPointId, 1);
  });

  test('search: door_to_door and missing fields default to fixed_point', () {
    final d = TripSearchResultModel.fromJson({
      "trip_id": 2,
      "route": {"route_id": 1, "name": {}},
      "vehicle": {"vehicle_id": 1, "vehicle_type": "van", "capacity": 10},
      "pickup_mode": "door_to_door",
      "end_point": {"latitude": "36.2021000", "longitude": "37.1343000"},
      "allow_route_pickup": true,
      "collection_points": [],
    });
    expect(d.pickupMode, PickupMode.doorToDoor);
    expect(d.allowRoutePickup, isTrue);
    expect(d.endPoint!.longitude, 37.1343);

    final old = TripSearchResultModel.fromJson({
      "trip_id": 3,
      "route": {"route_id": 1, "name": {}},
      "vehicle": {"vehicle_id": 1, "vehicle_type": "van", "capacity": 10},
    });
    expect(old.pickupMode, PickupMode.fixedPoint);
    expect(old.collectionPoints, isEmpty);
  });

  test('booking: pickup block parsed, null for fixed_point', () {
    final withPickup = BookingModel.fromJson({
      "booking_id": 1,
      "pickup": {
        "source": "collection_point",
        "collection_point_id": 1,
        "location_visible": true,
        "address": "Mezzeh roundabout",
        "latitude": "33.5200000",
        "longitude": "36.2900000",
        "coordinates_redacted": false,
      },
    });
    expect(withPickup.pickup!.isCollectionPoint, isTrue);
    expect(withPickup.pickup!.hasCoordinates, isTrue);
    expect(BookingModel.fromJson({"booking_id": 2, "pickup": null}).pickup,
        isNull);

    final redacted = BookingPickupModel.fromJson({
      "source": "gps",
      "location_visible": true,
      "address": "x",
      "latitude": null,
      "longitude": null,
      "coordinates_redacted": true,
    });
    expect(redacted.hasCoordinates, isFalse);
  });

  test('create booking dto: pickup only on scheduled trips', () {
    final json = CreateBookingDto.scheduledTrip(
      tripId: 1,
      tripSeatIds: [1],
      paymentMethod: "cash_on_delivery",
      idempotencyKey: "k",
      pickup: const PickupDto.location(
        source: "gps",
        latitude: 33.52,
        longitude: 36.29,
        address: "Mezzeh",
      ),
    ).toJson();
    expect(json["pickup"], {
      "source": "gps",
      "latitude": 33.52,
      "longitude": 36.29,
      "address": "Mezzeh",
    });
    expect(
      CreateBookingDto.scheduledTrip(
        tripId: 1,
        tripSeatIds: [1],
        paymentMethod: "wallet",
        idempotencyKey: "k",
      ).toJson().containsKey("pickup"),
      isFalse,
    );
    expect(const PickupDto.collectionPoint(4).toJson(), {
      "source": "collection_point",
      "collection_point_id": 4,
    });
  });

  test('tracking snapshot: null position / stop', () {
    final s = TrackingSnapshotModel.fromJson({
      "booking_id": 1,
      "booking_status": "confirmed",
      "trip_id": 1,
      "trip_status": "waiting",
      "pickup_mode": "collection_points",
      "pickup_phase": "not_started",
      "position": null,
      "eta_minutes": null,
      "eta_computed_at": null,
      "stop": null,
    });
    expect(s.position, isNull);
    expect(s.pickupPhase, "not_started");
    expect(s.stopSequence, isNull);

    final live = TrackingPositionModel.tryParse({
      "trip_id": 1,
      "latitude": 33.515,
      "longitude": 36.28,
      "heading": null,
      "recorded_at": "2026-09-30T10:08:10+00:00",
    });
    expect(live!.latitude, 33.515);
    expect(live.heading, isNull);
  });

  test('payment request + notification models', () {
    final r = PaymentRequestModel.fromJson({
      "payment_request_id": 17,
      "status": "pending",
      "amount": "20000.00",
      "currency": "SYP",
      "booking_id": 512,
      "seats_count": 2,
      "expires_at": "2026-08-31T09:15:00.000000Z",
      "seats": [
        {"trip_seat_id": 44, "seat_number": "1"},
      ],
    });
    expect(r.isPending, isTrue);
    expect(r.amount, "20000.00");

    final n = NotificationItemModel.fromJson({
      "notification_id": 2,
      "type": "campaign_service",
      "title": "Service update",
      "message": "New trip times",
      "is_read": false,
      "data": {"campaign_id": 1},
    });
    expect(n.title, "Service update");
    expect(n.data["campaign_id"], 1);
  });
}
