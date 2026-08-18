import 'package:tourify/core/network/api_service.dart';

class PlaceImage {
  final String path;
  final bool isMain;

  PlaceImage({required this.path, required this.isMain});

  factory PlaceImage.fromJson(Map<String, dynamic> json) {
    return PlaceImage(
      path: json["path"] ?? "",
      isMain: json["is_main"] == 1 || json["is_main"] == true,
    );
  }

  // بيبني الرابط الكامل بالاعتماد على baseUrl الموجود أصلاً بـ ApiService
  // بدون أي تعديل على ملف ApiService نفسه
  // ⚠️ رد الـ API بيرجع بس "1/xxx.jpg" بحقل path، بس الملف الحقيقي
  // عالسيرفر مخزّن جوا مجلد فئة اسمه "place/" (زي public/storage/place/1/xxx.jpg).
  // الباك ناقص يحط اسم الفئة بالـ path، فبنضيفها هون يدوياً كحل مؤقت.
  String get fullUrl {
    final storageBase = ApiService.baseUrl.replaceFirst('/api', '/storage/');
    return "${storageBase}place/$path";
  }
}

class PlaceModel {
  final int id;
  final int cityId;
  final String name;
  final String? url;
  final String description;
  final String? history;
  final double? averageRating;
  final List<PlaceImage> images;
  final bool isFavorite;

  PlaceModel({
    required this.id,
    required this.cityId,
    required this.name,
    this.url,
    required this.description,
    this.history,
    this.averageRating,
    required this.images,
    required this.isFavorite,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json["id"],
      cityId: json["city_id"],
      name: json["name"] ?? "",
      url: json["url"],
      description: json["description"] ?? "",
      history: json["history"],
      averageRating: json["average_rating"] != null
          ? double.tryParse(json["average_rating"].toString())
          : null,
      images: (json["images"] as List? ?? [])
          .map((e) => PlaceImage.fromJson(e))
          .toList(),
          isFavorite: json["is_favorite"] == true,
    );
  }

  // الصورة الرئيسية لعرضها بالكارد (is_main = true)، وإلا أول صورة بالقائمة
  String? get mainImageUrl {
    if (images.isEmpty) return null;
    final main = images.firstWhere(
      (img) => img.isMain,
      orElse: () => images.first,
    );
    return main.fullUrl;
  }
}
