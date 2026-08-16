import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/places/models/place_model.dart';

class GetPlaces {
  final ApiService apiService = ApiService();

  Future<List<PlaceModel>> getPlaces() async {
    final response = await apiService.get('/places');
    final List data = response['data'] ?? [];
    return data.map((place) => PlaceModel.fromJson(place)).toList();
  }
}
