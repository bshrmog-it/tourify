import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/agency/agency_view/models/agency_model.dart';

class GetAgencyDetails {
  final ApiService apiService = ApiService();

  Future<AgencyModel> getAgencyDetails(int id) async {
    final response = await apiService.get('/agencies/$id');
    return AgencyModel.fromJson(response['data']);
  }
}
