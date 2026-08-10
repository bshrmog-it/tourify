import 'package:tourify/features/package/models/flight_model.dart';

class AirlineModel {
  final int id;
  final String name;
  final List<FlightModel> flights;

  AirlineModel({required this.id, required this.name, required this.flights});

  factory AirlineModel.fromJson(Map<String, dynamic> json) {
    return AirlineModel(
      id: json['id'],
      name: json['name'],
      flights: (json['flights'] as List)
          .map((flight) => FlightModel.fromJson(flight))
          .toList(),
    );
  }
}
