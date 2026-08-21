import 'package:tourify/core/network/api_service.dart';

// موديل خفيف للعرض بالداشبورد بس — Travel Offices مش من مسؤوليتك،
// فما بنينا قسم كامل إلها متل باقي الأقسام.
class AgencyPreviewModel {
  final int id;
  final String name;
  final double? averageRating;
  final String? mainImageUrl;

  AgencyPreviewModel({
    required this.id,
    required this.name,
    this.averageRating,
    this.mainImageUrl,
  });

  factory AgencyPreviewModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    final images = json['images'] as List?;
    if (images != null && images.isNotEmpty) {
      final main = images.firstWhere(
        (img) => img['is_main'] == 1 || img['is_main'] == true,
        orElse: () => images.first,
      );
      final storageBase = ApiService.baseUrl.replaceFirst('/api', '/storage/');
      imageUrl = '${storageBase}agency/${main['path']}';
    }
    return AgencyPreviewModel(
      id: json['id'],
      name: json['name'] ?? '',
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString())
          : null,
      mainImageUrl: imageUrl,
    );
  }
}
