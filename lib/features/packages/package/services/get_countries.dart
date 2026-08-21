import 'package:tourify/core/network/api_service.dart';
import '../models/country_model.dart';

class GetCountries {
  final ApiService api = ApiService();

  Future<List<CountryModel>> getCountries() async {
    final response = await api.get("/country");

    final List data = response["data"];

    return data.map((e) => CountryModel.fromJson(e)).toList();
  }
}
