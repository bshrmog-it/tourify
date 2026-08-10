import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/package/models/resturent_model.dart';

class GetRestaurants {
  final ApiService apiService = ApiService();

  Future<List<RestaurantModel>> getRestaurants({
    required int countryId,
    required int cityId,
  }) async {
    final response = await apiService.get(
      '/restaurants-drop-list',
      queryParameters: {'country_id': countryId, 'city_id': cityId},
    );

    final List data = response['data'] ?? [];

    return data
        .map((restaurant) => RestaurantModel.fromJson(restaurant))
        .toList();
  }
}
