import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/packages/package/models/hotel_model.dart';

class GetHotels {
  final ApiService apiService = ApiService();

  Future<List<HotelModel>> getHotels({
    required int countryId,
    required int cityId,
  }) async {
    final response = await apiService.get(
      '/hotels-drop-list',
      queryParameters: {
        'country_id': countryId,
        'city_id': cityId,
      },
    );

    final List data = response['data'] ?? [];

    return data
        .map(
          (hotel) => HotelModel.fromJson(hotel),
        )
        .toList();
  }
}