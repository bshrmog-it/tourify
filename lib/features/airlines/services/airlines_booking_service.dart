import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/airlines/models/flight_booking_model.dart';

class AirlinesBookingService {
  AirlinesBookingService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// The backend expects the FlightSchedule ID here.
  /// No request body is required.
  Future<FlightBookingModel> bookFlightSchedule(int scheduleId) async {
    final response = await _apiService.post(
      '/flights/$scheduleId/book',
      data: {},
    );

    final data = Map<String, dynamic>.from(response['data']);
    return FlightBookingModel.fromJson(data);
  }
}
