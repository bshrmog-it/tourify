import '../../../core/network/api_service.dart';
import '../models/dropdown_flight_model.dart';

class GetFlightsDropdownService {
  final ApiService _apiService = ApiService();

  Future<List<DropdownFlightModel>> getFlights() async {
    final response = await _apiService.get('/flights/dropdown');
    final List data = response['data'];
    return data.map((e) => DropdownFlightModel.fromJson(e)).toList();
  }
}
