import 'package:tourify/core/network/api_service.dart';

class RestaurantImage {
  final String path;
  final bool isMain;

  RestaurantImage({required this.path, required this.isMain});

  factory RestaurantImage.fromJson(Map<String, dynamic> json) {
    return RestaurantImage(
      path: json["path"] ?? "",
      isMain: json["is_main"] == 1 || json["is_main"] == true,
    );
  }

  String get fullUrl {
    final storageBase = ApiService.baseUrl.replaceFirst('/api', '/storage/');
    return "${storageBase}restaurant/$path";
  }
}

class RestaurantModel {
  final int id;
  final int cityId;
  final String name;
  final String description;
  final String? phone;
  final double? averageRating;
  final List<RestaurantImage> images;
  final bool isFavorite;

  RestaurantModel({
    required this.id,
    required this.cityId,
    required this.name,
    required this.description,
    this.phone,
    this.averageRating,
    required this.images,
    required this.isFavorite,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json["id"],
      cityId: json["city_id"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      phone: json["phone"],
      averageRating: json["average_rating"] != null
          ? double.tryParse(json["average_rating"].toString())
          : null,
      images: (json["images"] as List? ?? [])
          .map((e) => RestaurantImage.fromJson(e))
          .toList(),
      isFavorite: json["is_favorite"] == true,
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
}
