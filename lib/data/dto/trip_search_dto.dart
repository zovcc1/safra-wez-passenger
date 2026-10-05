class TripSearchDto {
  final int originGovernorateId;
  final int destinationGovernorateId;
  final DateTime? departureDateFrom;
  final DateTime? departureDateTo;
  final int? seatsNeeded;
  final String? vehicleType;
  final bool includeOpenTrips;
  final String? cursor;

  const TripSearchDto({
    required this.originGovernorateId,
    required this.destinationGovernorateId,
    this.departureDateFrom,
    this.departureDateTo,
    this.seatsNeeded,
    this.vehicleType,
    this.includeOpenTrips = true,
    this.cursor,
  });

  String _formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  Map<String, dynamic> toQueryParameters() => {
    "origin_governorate_id": originGovernorateId,
    "destination_governorate_id": destinationGovernorateId,
    if (departureDateFrom != null)
      "departure_date_from": _formatDate(departureDateFrom!),
    if (departureDateTo != null)
      "departure_date_to": _formatDate(departureDateTo!),
    if (seatsNeeded != null) "seats_needed": seatsNeeded,
    if (vehicleType != null) "vehicle_type": vehicleType,
    "include_open_trips": includeOpenTrips,
    if (cursor != null) "cursor": cursor,
  };
}
