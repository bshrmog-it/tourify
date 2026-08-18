class FlightCity {
  final int id;
  final String name;

  const FlightCity({
    required this.id,
    required this.name,
  });

  factory FlightCity.fromJson(Map<String, dynamic> json) {
    return FlightCity(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
    );
  }
}

class FlightModel {
  final int id;
  final int airlineId;
  final int fromCityId;
  final int toCityId;
  final double price;
  final FlightCity fromCity;
  final FlightCity toCity;

  const FlightModel({
    required this.id,
    required this.airlineId,
    required this.fromCityId,
    required this.toCityId,
    required this.price,
    required this.fromCity,
    required this.toCity,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json['id'] as int,
      airlineId: json['airline_id'] as int,
      fromCityId: json['from_city_id'] as int,
      toCityId: json['to_city_id'] as int,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      fromCity: FlightCity.fromJson(
        Map<String, dynamic>.from(json['from_city'] ?? {}),
      ),
      toCity: FlightCity.fromJson(
        Map<String, dynamic>.from(json['to_city'] ?? {}),
      ),
    );
  }
}
