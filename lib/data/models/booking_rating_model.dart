/// تقييم الحجز — نهائي (لا تعديل ولا حذف)، ويُعرض Read-only. comment=null
/// يعني إمّا ما كتب المسافر تعليقًا أو أدمن أخفاه، والحالتان تُعرضان بنفس الشكل.
class BookingRatingModel {
  final int ratingId;
  final int providerScore;
  final int vehicleScore;
  final String? comment;
  final DateTime? createdAt;

  const BookingRatingModel({
    required this.ratingId,
    required this.providerScore,
    required this.vehicleScore,
    this.comment,
    this.createdAt,
  });

  factory BookingRatingModel.fromJson(Map<String, dynamic> json) =>
      BookingRatingModel(
        ratingId: json["rating_id"] ?? 0,
        providerScore: json["provider_score"] ?? 0,
        vehicleScore: json["vehicle_score"] ?? 0,
        comment: json["comment"],
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
      );
}
