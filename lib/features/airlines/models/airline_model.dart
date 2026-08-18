class AirlineModel {
  final int id;
  final String name;
  final double credit;
  final double? averageRating;
  final bool isFavorite;

  const AirlineModel({
    required this.id,
    required this.name,
    required this.credit,
    required this.averageRating,
    required this.isFavorite,
  });

  factory AirlineModel.fromJson(Map<String, dynamic> json) {
    return AirlineModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      credit: double.tryParse(json['credit']?.toString() ?? '') ?? 0,
      averageRating: json['average_rating'] == null
          ? null
          : double.tryParse(json['average_rating'].toString()),
      isFavorite: json['is_favorite'] == true,
    );
  }
}
