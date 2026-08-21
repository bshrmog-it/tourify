class DropdownFlightModel {
  final int id;
  final String text;
  final String fromCity;
  final String toCity;
  final double price;
  final int fromCityId;
  final int toCityId;

  DropdownFlightModel({
    required this.id,
    required this.text,
    required this.fromCity,
    required this.toCity,
    required this.price,
    required this.fromCityId,
    required this.toCityId,
  });

  factory DropdownFlightModel.fromJson(Map<String, dynamic> json) {
    return DropdownFlightModel(
      id: json['id'],
      text: json['text'] ?? '',
      fromCity: json['from_city'] ?? '',
      toCity: json['to_city'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      fromCityId: json['from_city_id'],
      toCityId: json['to_city_id'],
    );
  }
}
