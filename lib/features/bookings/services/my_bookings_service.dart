import '../../../core/network/api_service.dart';
import '../models/booking_model.dart';
import '../models/booking_group.dart';

class MyBookingsService {
  final ApiService _apiService = ApiService();

  Future<GroupedBookings> getMyBookings() async {
    final response = await _apiService.get('/dashboard/bookings');
    final List data = response['data']['bookings'];
    final all = data.map((e) => BookingModel.fromJson(e)).toList();
    return GroupedBookings.fromRaw(all);
  }

  Future<void> cancelPackageBooking({
    required int packageId,
    required int bookingId,
  }) async {
    await _apiService.delete('/packages/$packageId/bookings/$bookingId/cancel');
  }
}
