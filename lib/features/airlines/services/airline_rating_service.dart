import 'package:tourify/core/network/api_service.dart';

class AirlineRatingService {
  AirlineRatingService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<void> rateAirline({
    required int airlineId,
    required int rating,
  }) async {
    await _apiService.post(
      '/airlines/$airlineId/rate',
      data: {'rating': rating},
    );
  }
}
