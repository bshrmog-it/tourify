import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/places/models/place_model.dart';
import 'package:tourify/features/hotels/models/hotel_model.dart';
import 'package:tourify/features/restaurants/models/restaurant_model.dart';
import 'package:tourify/features/agency/agency_view/models/agency_model.dart';
import 'package:tourify/features/airlines/models/airline_model.dart';

class DashboardFavorites {
  final List<PlaceModel> places;
  final List<HotelModel> hotels;
  final List<RestaurantModel> restaurants;
  final List<AgencyModel> agencies;
  final List<AirlineModel> airlines;

  DashboardFavorites({
    required this.places,
    required this.hotels,
    required this.restaurants,
    required this.agencies,
    required this.airlines,
  });
}

class GetDashboardFavorites {
  final ApiService apiService = ApiService();

  Future<DashboardFavorites> getFavorites() async {
    final response = await apiService.get('/dashboard/favorites');
    final data = response['data'] ?? {};

    // places/hotels/restaurants: كل عنصر فيه "favoriteable" (الكائن الكامل)
    List<T> parseNested<T>(
        String key, T Function(Map<String, dynamic>) fromJson) {
      final List items = (data[key] as List?) ?? [];
      return items
          .where((e) => e['favoriteable'] != null)
          .map((e) => fromJson(e['favoriteable'] as Map<String, dynamic>))
          .toList();
    }

    // agencies/airlines: العناصر هون بس فيها favoriteable_id (بدون بيانات
    // كاملة)، فلازم نجيب القائمة الكاملة ونفلترها لبس المفضّل منها.
    final agencyIds = ((data['agencies'] as List?) ?? [])
        .map((e) => e['favoriteable_id'] as int)
        .toSet();
    final airlineIds = ((data['airlines'] as List?) ?? [])
        .map((e) => e['favoriteable_id'] as int)
        .toSet();

    List<AgencyModel> favoriteAgencies = [];
    if (agencyIds.isNotEmpty) {
      final agenciesResponse = await apiService.get('/agencies');
      final List allAgencies = agenciesResponse['data'] ?? [];
      favoriteAgencies = allAgencies
          .map((e) => AgencyModel.fromJson(e))
          .where((a) => agencyIds.contains(a.id))
          .toList();
    }

    List<AirlineModel> favoriteAirlines = [];
    if (airlineIds.isNotEmpty) {
      final airlinesResponse = await apiService.get('/airlines');
      final List allAirlines = airlinesResponse['data'] ?? [];
      favoriteAirlines = allAirlines
          .map((e) => AirlineModel.fromJson(e))
          .where((a) => airlineIds.contains(a.id))
          .toList();
    }

    return DashboardFavorites(
      places: parseNested('places', PlaceModel.fromJson),
      hotels: parseNested('hotels', HotelModel.fromJson),
      restaurants: parseNested('restaurants', RestaurantModel.fromJson),
      agencies: favoriteAgencies,
      airlines: favoriteAirlines,
    );
  }
}
