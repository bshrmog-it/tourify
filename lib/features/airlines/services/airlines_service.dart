import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/airlines/models/airline_model.dart';
import 'package:tourify/features/airlines/models/flight_model.dart';
import 'package:tourify/features/airlines/models/flight_schedule_model.dart';

class AirlinesService {
  AirlinesService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<AirlineModel>> getAirlines() async {
    final response = await _apiService.get('/airlines');
    final data = List<Map<String, dynamic>>.from(response['data']);
    return data.map(AirlineModel.fromJson).toList();
  }

  Future<List<FlightModel>> getFlights(int airlineId) async {
    final response = await _apiService.get('/airlines/$airlineId/flights');
    final data = List<Map<String, dynamic>>.from(response['data']);
    return data.map(FlightModel.fromJson).toList();
  }

  Future<List<FlightScheduleModel>> getSchedules(int flightId) async {
    final response = await _apiService.get('/flights/$flightId/schedules');
    final data = List<Map<String, dynamic>>.from(response['data']);
    return data.map(FlightScheduleModel.fromJson).toList();
  }
}
