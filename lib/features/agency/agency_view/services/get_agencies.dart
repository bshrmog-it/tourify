import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/agency/agency_view/models/agency_model.dart';

class GetAgencies {
  final ApiService apiService = ApiService();

  Future<List<AgencyModel>> getAgencies() async {
    final response = await apiService.get('/agencies');
    final List data = response['data'] ?? [];
    return data.map((e) => AgencyModel.fromJson(e)).toList();
  }
}
