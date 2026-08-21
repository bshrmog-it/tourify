import 'package:tourify/core/network/api_service.dart';

class PackageActionsService {
  final ApiService apiService = ApiService();

  Future<void> bookPackage(int packageId) async {
    await apiService.post('/packages/book', data: {'package_id': packageId});
  }
}
