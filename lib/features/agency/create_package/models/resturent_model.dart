class RestaurantModel {
  final int id;
  final String name;
  final String description;
  final String phone;
  final String? image;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    this.image,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      image: json['images'] != null && (json['images'] as List).isNotEmpty
          ? json['images'][0]['url']
          : null,
    );
  }
}
