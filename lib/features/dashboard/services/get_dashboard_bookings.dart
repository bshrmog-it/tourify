import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/dashboard/models/booking_model.dart';

class GetDashboardBookings {
  final ApiService apiService = ApiService();

  Future<List<BookingModel>> getBookings() async {
    final response = await apiService.get('/dashboard/bookings');
    final List data = response['data']?['bookings'] ?? [];
    return data.map((e) => BookingModel.fromJson(e)).toList();
  }
}
