class HotelModel {
  final int id;
  final String name;
  final String description;
  final String phone;
  final String? image;
  final List<String> roomTypes;

  HotelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.roomTypes,
    this.image,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      roomTypes: List<String>.from(json['room_types'] ?? []),
      image: json['images'] != null && (json['images'] as List).isNotEmpty
          ? json['images'][0]['url']
          : null,
    );
  }
}
