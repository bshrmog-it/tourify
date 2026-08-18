import 'package:tourify/core/network/api_service.dart';

import '../models/active_package_model.dart';
import '../models/package_booking_model.dart';

class AgencyPackageService {
  final ApiService _apiService = ApiService();

  Future<List<ActivePackageModel>> getActivePackages() async {
    final response = await _apiService.get('/agency/packages/active');
    final List data = response['data'];
    return data.map((e) => ActivePackageModel.fromJson(e)).toList();
  }

  Future<List<PackageBookingModel>> getPendingBookings(int packageId) async {
    final response = await _apiService.get(
      '/agencies/packages/$packageId/bookings/pending',
    );
    final List data = response['data'];
    return data.map((e) => PackageBookingModel.fromJson(e)).toList();
  }

  Future<void> approveBooking(int packageId, int bookingId) async {
    await _apiService.post(
      '/agencies/packages/$packageId/bookings/$bookingId/approve',
      data: {},
    );
  }

  Future<void> rejectBooking(int packageId, int bookingId) async {
    await _apiService.post(
      '/agencies/packages/$packageId/bookings/$bookingId/reject',
      data: {},
    );
  }
}
