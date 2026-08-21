import 'package:tourify/core/network/api_service.dart';

class AgencyImage {
  final String path;
  final bool isMain;

  AgencyImage({required this.path, required this.isMain});

  factory AgencyImage.fromJson(Map<String, dynamic> json) {
    return AgencyImage(
      path: json["path"] ?? "",
      isMain: json["is_main"] == 1 || json["is_main"] == true,
    );
  }

  String get fullUrl {
    final storageBase = ApiService.baseUrl.replaceFirst('/api', '/storage/');
    return "${storageBase}agency/$path";
  }
}

// ملخص باكج الوكالة (من رد /api/agencies/{id} فقط، بدون تفاصيل الأيام)
class AgencyPackageSummary {
  final int id;
  final String name;
  final String description;
  final int numberOfDays;
  final String roomType;
  final double price;
  final int quantity;

  AgencyPackageSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.numberOfDays,
    required this.roomType,
    required this.price,
    required this.quantity,
  });

  factory AgencyPackageSummary.fromJson(Map<String, dynamic> json) {
    return AgencyPackageSummary(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      numberOfDays: json['number_of_days'] ?? 0,
      roomType: json['room_type'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }
}

class AgencyModel {
  final int id;
  final String name;
  final String? landlinePhone;
  final String? address;
  final String description;
  final double? averageRating;
  final bool isFavorite;
  final List<AgencyImage> images;
  final List<AgencyPackageSummary> packages;

  AgencyModel({
    required this.id,
    required this.name,
    this.landlinePhone,
    this.address,
    required this.description,
    this.averageRating,
    required this.isFavorite,
    required this.images,
    this.packages = const [],
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: json['id'],
      name: json['name'] ?? '',
      landlinePhone: json['landline_phone'],
      address: json['address'],
      description: json['description'] ?? '',
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString())
          : null,
      isFavorite: json['is_favorite'] == true,
      images: ((json['images'] as List?) ?? [])
          .map((e) => AgencyImage.fromJson(e))
          .toList(),
      packages: ((json['packages'] as List?) ?? [])
          .map((e) => AgencyPackageSummary.fromJson(e))
          .toList(),
    );
  }

  String? get mainImageUrl {
    if (images.isEmpty) return null;
    final main =
        images.firstWhere((img) => img.isMain, orElse: () => images.first);
    return main.fullUrl;
  }
}
