import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/places/models/place_model.dart';
import 'package:tourify/features/hotels/models/hotel_model.dart';
import 'package:tourify/features/restaurants/models/restaurant_model.dart';
import 'package:tourify/features/airlines/models/airline_model.dart';
import 'package:tourify/features/dashboard/models/agency_preview_model.dart';

class DashboardData {
  final List<PlaceModel> places;
  final List<RestaurantModel> restaurants;
  final List<HotelModel> hotels;
  final List<AirlineModel> airlines;
  final List<AgencyPreviewModel> agencies;

  DashboardData({
    required this.places,
    required this.restaurants,
    required this.hotels,
    required this.airlines,
    required this.agencies,
  });
}

class GetDashboard {
  final ApiService apiService = ApiService();

  Future<DashboardData> getDashboard({String? country}) async {
    final response = await apiService.get(
      '/dashboard',
      queryParameters: country != null ? {'country': country} : null,
    );
    final data = response['data'] ?? {};
    return DashboardData(
      places: ((data['places'] as List?) ?? [])
          .map((e) => PlaceModel.fromJson(e))
          .toList(),
      restaurants: ((data['restaurants'] as List?) ?? [])
          .map((e) => RestaurantModel.fromJson(e))
          .toList(),
      hotels: ((data['hotels'] as List?) ?? [])
          .map((e) => HotelModel.fromJson(e))
          .toList(),
      airlines: ((data['airlines'] as List?) ?? [])
          .map((e) => AirlineModel.fromJson(e))
          .toList(),
      agencies: ((data['agencies'] as List?) ?? [])
          .map((e) => AgencyPreviewModel.fromJson(e))
          .toList(),
    );
  }
}
