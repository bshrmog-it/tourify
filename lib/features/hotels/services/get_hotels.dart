import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/hotels/models/hotel_model.dart';

class GetHotels {
  final ApiService apiService = ApiService();

  Future<List<HotelModel>> getHotels() async {
    final response = await apiService.get('/hotels');
    final List data = response['data'] ?? [];
    return data.map((hotel) => HotelModel.fromJson(hotel)).toList();
  }
}
