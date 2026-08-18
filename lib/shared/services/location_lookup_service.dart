import 'package:tourify/core/network/api_service.dart';

// Service مستقل (Singleton) بيجيب الدول ومدنها من /api/country مرة وحدة بس،
// وبيبني خريطة city_id -> "اسم المدينة, اسم الدولة" لاستخدامها بأي واجهة
// محتاجة تعرض اسم المدينة بدل الـ ID الخام. مصمم يكون قابل لإعادة الاستخدام
// من أي feature تاني بالمشروع (مش خاص بـ Places بس).
class LocationLookupService {
  LocationLookupService._internal();
  static final LocationLookupService instance =
      LocationLookupService._internal();

  final ApiService apiService = ApiService();

  Map<int, String>? _cache;
  Future<Map<int, String>>? _pendingFetch;

  Future<Map<int, String>> getCityLabels() async {
    if (_cache != null) return _cache!;
    _pendingFetch ??= _fetchAndBuildMap();
    return _pendingFetch!;
  }

  Future<Map<int, String>> _fetchAndBuildMap() async {
    final response = await apiService.get('/country');
    final List countries = response['data'] ?? [];
    final map = <int, String>{};

    for (final country in countries) {
      final countryName = country['name'] ?? '';
      // ⚠️ افتراض: كل دولة برجع جواها مصفوفة "cities" (eager-loaded).
      // إذا الاسم الحقيقي للمفتاح مختلف بالرد الفعلي، بدّله هون.
      final List cities = country['cities'] ?? [];
      for (final city in cities) {
        final cityId = city['id'];
        final cityName = city['name'] ?? '';
        if (cityId != null) {
          map[cityId] = countryName.isNotEmpty
              ? '$cityName, $countryName'
              : cityName;
        }
      }
    }

    _cache = map;
    return map;
  }
}
