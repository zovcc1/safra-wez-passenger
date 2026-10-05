class FileComplaintDto {
  final String category;
  final String description;
  final int? bookingId;

  const FileComplaintDto({
    required this.category,
    required this.description,
    this.bookingId,
  });

  Map<String, dynamic> toJson() => {
    "category": category,
    "description": description.trim(),
    if (bookingId != null) "booking_id": bookingId,
  };
}
