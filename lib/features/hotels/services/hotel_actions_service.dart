import 'package:tourify/core/network/api_service.dart';

class HotelActionsService {
  final ApiService apiService = ApiService();

  Future<void> rateHotel(int hotelId, int rating) async {
    await apiService.post(
      '/hotels/$hotelId/rate',
      data: {"rating": rating.toString()},
    );
  }
}
