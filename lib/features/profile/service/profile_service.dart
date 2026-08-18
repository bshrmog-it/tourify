import 'package:tourify/features/profile/model/profile_model.dart';

import '../../../core/network/api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  Future<ProfileModel> getProfile() async {
    final response = await _apiService.get('/profile');
    return ProfileModel.fromJson(response['data']['user']);
  }
}
