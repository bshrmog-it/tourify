import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/places/models/place_model.dart';

class GetPlaceDetails {
  final ApiService apiService = ApiService();

  Future<PlaceModel> getPlaceDetails(int id) async {
    final response = await apiService.get('/places/$id');
    return PlaceModel.fromJson(response['data']);
  }
}
