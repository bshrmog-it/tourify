class FlightScheduleModel {
  final int id;
  final int flightId;
  final String date;
  final String departureTime;
  final String arrivalTime;
  final int seats;

  const FlightScheduleModel({
    required this.id,
    required this.flightId,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.seats,
  });

  factory FlightScheduleModel.fromJson(Map<String, dynamic> json) {
    return FlightScheduleModel(
      id: json['id'] as int,
      flightId: json['flight_id'] as int,
      date: json['date']?.toString() ?? '',
      departureTime: json['departure_time']?.toString() ?? '',
      arrivalTime: json['arrival_time']?.toString() ?? '',
      seats: (json['seats'] as num?)?.toInt() ?? 0,
    );
  }
}
