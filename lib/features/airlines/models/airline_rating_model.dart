class AirlineRatingModel {
  final int rating;

  const AirlineRatingModel({required this.rating});

  factory AirlineRatingModel.fromJson(Map<String, dynamic> json) {
    return AirlineRatingModel(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
    );
  }
}
