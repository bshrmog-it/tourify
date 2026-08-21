class PlaceModel {
  final int id;
  final String name;
  final String description;
  final List<String> images;

  PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json["id"],
      name: json["name"],
      description: json["description"] ?? "",
      images: (json["images"] as List).map((e) => e["url"] as String).toList(),
    );
  }
}
