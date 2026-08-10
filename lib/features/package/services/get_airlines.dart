import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/package/models/airline_model.dart';

class GetAirlines {
  final ApiService apiService = ApiService();

  Future<List<AirlineModel>> getAirlines({
    required int countryId,
    required int cityId,
  }) async {
    final response = await apiService.get(
      '/airlines-drop-list',
      queryParameters: {'country_id': countryId, 'city_id': cityId},
    );

    final List data = response is List ? response : response['data'] ?? [];

    return data.map((airline) => AirlineModel.fromJson(airline)).toList();
  }
}
