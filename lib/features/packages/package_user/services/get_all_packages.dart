import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/packages/package_user/models/package_model.dart';

class GetAllPackages {
  final ApiService apiService = ApiService();

  Future<List<PackageModel>> getAllPackages() async {
    final response = await apiService.get('/all-packages');
    final List data = response['data'] ?? [];
    return data.map((e) => PackageModel.fromJson(e)).toList();
  }
}
