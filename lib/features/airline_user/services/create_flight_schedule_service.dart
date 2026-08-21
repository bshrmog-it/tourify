import '../../../core/network/api_service.dart';

class CreateFlightScheduleService {
  final ApiService _apiService = ApiService();

  Future<void> createSchedule({
    required int flightId,
    required String departureTime,
    required String arrivalTime,
    required String startDate,
    required int weeks,
    required List<int> daysOfWeek,
  }) async {
    await _apiService.post(
      '/flight-schedules',
      data: {
        'flight_id': flightId,
        'departure_time': departureTime,
        'arrival_time': arrivalTime,
        'start_date': startDate,
        'weeks': weeks,
        'days_of_week': daysOfWeek,
      },
    );
  }
}
