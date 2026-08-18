import 'package:tourify/core/network/api_service.dart';

class RestaurantActionsService {
  final ApiService apiService = ApiService();

  Future<void> toggleFavorite(int restaurantId) async {
    await apiService.post('/restaurants/$restaurantId/favorite', data: {});
  }

  Future<void> rateRestaurant(int restaurantId, int rating) async {
    await apiService.post(
      '/restaurants/$restaurantId/rate',
      data: {"rating": rating.toString()},
    );
  }
}
