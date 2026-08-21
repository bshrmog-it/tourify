
import '../models/place_model.dart';
import '../../../../core/network/api_service.dart';

class GetPlaces {
  final ApiService apiService = ApiService();

  Future<List<PlaceModel>> getPlaces({
    required int countryId,
    required int cityId,
  }) async {
    final response = await apiService.get(
      '/places-drop-list',
      queryParameters: {'country_id': countryId, 'city_id': cityId},
    );

    final List data = response['data'] ?? [];

    return data.map((place) => PlaceModel.fromJson(place)).toList();
  }

}
