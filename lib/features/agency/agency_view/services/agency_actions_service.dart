import 'package:tourify/core/network/api_service.dart';

class AgencyActionsService {
  final ApiService apiService = ApiService();

  Future<void> rateAgency(int agencyId, int rating) async {
    await apiService.post(
      '/agencies/$agencyId/rate',
      data: {"rating": rating.toString()},
    );
  }
}
