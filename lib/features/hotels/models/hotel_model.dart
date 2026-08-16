import 'package:tourify/core/network/api_service.dart';

class HotelImage {
  final String path;
  final bool isMain;

  HotelImage({required this.path, required this.isMain});

  factory HotelImage.fromJson(Map<String, dynamic> json) {
    return HotelImage(
      path: json["path"] ?? "",
      isMain: json["is_main"] == 1 || json["is_main"] == true,
    );
  }

  String get fullUrl {
    final storageBase = ApiService.baseUrl.replaceFirst('/api', '/storage/');
    return "${storageBase}hotel/$path";
  }
}

class HotelRoom {
  final int id;
  final String type;
  final int capacity;
  final double price;

  HotelRoom({
    required this.id,
    required this.type,
    required this.capacity,
    required this.price,
  });

  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    return HotelRoom(
      id: json["id"],
      type: json["type"] ?? "",
      capacity: json["capacity"] ?? 0,
      price: double.tryParse(json["price"].toString()) ?? 0,
    );
  }
}

class HotelModel {
  final int id;
  final int cityId;
  final String name;
  final String description;
  final String phone;
  final double? averageRating;
  final bool isFavorite;
  final List<HotelImage> images;
  final List<HotelRoom> rooms;

  HotelModel({
    required this.id,
    required this.cityId,
    required this.name,
    required this.description,
    required this.phone,
    this.averageRating,
    required this.isFavorite,
    required this.images,
    required this.rooms,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json["id"],
      cityId: json["city_id"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      phone: json["phone"] ?? "",
      averageRating: json["average_rating"] != null
          ? double.tryParse(json["average_rating"].toString())
          : null,
      isFavorite: json["is_favorite"] == true,
      images: (json["images"] as List? ?? [])
          .map((e) => HotelImage.fromJson(e))
          .toList(),
      rooms: (json["rooms"] as List? ?? [])
          .map((e) => HotelRoom.fromJson(e))
          .toList(),
    );
  }

  String? get mainImageUrl {
    if (images.isEmpty) return null;
    final main = images.firstWhere(
      (img) => img.isMain,
      orElse: () => images.first,
    );
    return main.fullUrl;
  }

  // بتجمع الغرف حسب النوع (كل غرف النوع الواحد نفس السعر والسعة)
  Map<String, List<HotelRoom>> get roomsByType {
    final map = <String, List<HotelRoom>>{};
    for (final room in rooms) {
      map.putIfAbsent(room.type, () => []).add(room);
    }
    return map;
  }
}
