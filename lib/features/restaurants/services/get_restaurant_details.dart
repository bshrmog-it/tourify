import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/restaurants/models/restaurant_model.dart';

class GetRestaurantDetails {
  final ApiService apiService = ApiService();

  Future<RestaurantModel> getRestaurantDetails(int id) async {
    final response = await apiService.get('/restaurants/$id');
    return RestaurantModel.fromJson(response['data']);
  }
}
