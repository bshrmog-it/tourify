import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/hotels/models/hotel_model.dart';

class GetHotelDetails {
  final ApiService apiService = ApiService();

  Future<HotelModel> getHotelDetails(int id) async {
    final response = await apiService.get('/hotels/$id');
    return HotelModel.fromJson(response['data']);
  }
}
