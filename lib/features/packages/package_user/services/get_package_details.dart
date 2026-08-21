import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/packages/package_user/models/package_model.dart';

class GetPackageDetails {
  final ApiService apiService = ApiService();

  Future<PackageModel> getPackageDetails(int id) async {
    final response = await apiService.get('/package/$id/details');
    return PackageModel.fromJson(response['data']);
  }
}
