class FlightModel {
  final int id;
  final int airlineId;

  final int fromCityId;
  final int toCityId;

  final String fromCity;
  final String toCity;

  final double price;

  final List<FlightScheduleModel> schedules;

  FlightModel({
    required this.id,
    required this.airlineId,
    required this.fromCityId,
    required this.toCityId,
    required this.fromCity,
    required this.toCity,
    required this.price,
    required this.schedules,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json['id'],
      airlineId: json['airline_id'],
      fromCityId: json['from_city_id'],
      toCityId: json['to_city_id'],

      fromCity: json['from_city']['name'],
      toCity: json['to_city']['name'],

      price: double.parse(json['price'].toString()),

      schedules: (json['schedules'] as List? ?? [])
          .map((e) => FlightScheduleModel.fromJson(e))
          .toList(),
    );
  }
}

class FlightScheduleModel {
  final int id;
  final int flightId;
  final String date;
  final String departure;
  final String arrival;
  final int seats;

  FlightScheduleModel({
    required this.id,
    required this.flightId,
    required this.date,
    required this.departure,
    required this.arrival,
    required this.seats,
  });

  factory FlightScheduleModel.fromJson(Map<String, dynamic> json) {
    return FlightScheduleModel(
      id: json['id'],
      flightId: json['flight_id'],
      date: json['date'].toString(),
      departure: json['departure_time'].toString(),
      arrival: json['arrival_time'].toString(),
      seats: json['seats'] ?? 0,
    );
  }
}
