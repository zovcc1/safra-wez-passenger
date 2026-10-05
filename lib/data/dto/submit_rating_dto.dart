class SubmitRatingDto {
  final int providerScore;
  final int vehicleScore;
  final String? comment;

  const SubmitRatingDto({
    required this.providerScore,
    required this.vehicleScore,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    "provider_score": providerScore,
    "vehicle_score": vehicleScore,
    if (comment != null && comment!.trim().isNotEmpty)
      "comment": comment!.trim(),
  };
}
