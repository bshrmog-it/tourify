class FlightModel {
  final int id;
  final int airlineId;
  final int fromCityId;
  final int toCityId;
  final String fromCity;
  final String toCity;
  final double price;
  final String? departure;

  final String? arrival;

  FlightModel({
    required this.id,
    required this.airlineId,
    required this.fromCityId,
    required this.toCityId,
    required this.fromCity,
    required this.toCity,
    required this.price,
    this.departure,
    this.arrival,
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
      departure: json['departure'],
      arrival: json['arrival'],
    );
  }
}
