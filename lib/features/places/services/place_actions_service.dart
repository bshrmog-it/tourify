import 'package:tourify/core/network/api_service.dart';

class PlaceActionsService {
  final ApiService apiService = ApiService();

  Future<void> toggleFavorite(int placeId) async {
    await apiService.post('/places/$placeId/favorite', data: {});
  }

  Future<void> ratePlace(int placeId, int rating) async {
    await apiService.post(
      '/places/$placeId/rate',
      data: {"rating": rating.toString()},
    );
  }
}
