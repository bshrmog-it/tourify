import 'package:tourify/core/network/api_service.dart';

// Service مستقل (Singleton) بيجيب الدول ومدنها من /api/country مرة وحدة بس،
// وبيبني خريطة city_id -> "اسم المدينة, اسم الدولة" + قائمة أسماء الدول،
// لاستخدامها بأي واجهة بالمشروع (مش خاص بـ Places بس).
class LocationLookupService {
  LocationLookupService._internal();
  static final LocationLookupService instance =
      LocationLookupService._internal();

  final ApiService apiService = ApiService();

  Map<int, String>? _cityLabelsCache;
  List<String>? _countryNamesCache;
  Future<void>? _pendingFetch;

  Future<Map<int, String>> getCityLabels() async {
    await _ensureFetched();
    return _cityLabelsCache!;
  }

  Future<List<String>> getCountryNames() async {
    await _ensureFetched();
    return _countryNamesCache!;
  }

  Future<void> _ensureFetched() async {
    if (_cityLabelsCache != null && _countryNamesCache != null) return;
    _pendingFetch ??= _fetchAndBuild();
    await _pendingFetch;
  }

  Future<void> _fetchAndBuild() async {
    final response = await apiService.get('/country');
    final List countries = response['data'] ?? [];
    final cityMap = <int, String>{};
    final countryNames = <String>[];

    for (final country in countries) {
      final countryName = country['name'] ?? '';
      if (countryName.isNotEmpty) countryNames.add(countryName);
      final List cities = country['cities'] ?? [];
      for (final city in cities) {
        final cityId = city['id'];
        final cityName = city['name'] ?? '';
        if (cityId != null) {
          cityMap[cityId] = countryName.isNotEmpty
              ? '$cityName, $countryName'
              : cityName;
        }
      }
    }

    _cityLabelsCache = cityMap;
    _countryNamesCache = countryNames;
  }
}
