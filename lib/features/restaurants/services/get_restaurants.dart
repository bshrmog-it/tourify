import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/restaurants/models/restaurant_model.dart';

class GetRestaurants {
  final ApiService apiService = ApiService();

  Future<List<RestaurantModel>> getRestaurants() async {
    final response = await apiService.get('/restaurants');
    final List data = response['data'] ?? [];
    return data.map((restaurant) => RestaurantModel.fromJson(restaurant)).toList();
  }
}
