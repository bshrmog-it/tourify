import 'city_model.dart';

class CountryModel {
  final int id;
  final String name;
  final String flag;
  final List<CityModel> cities;

  CountryModel({
    required this.id,
    required this.name,
    required this.flag,
    required this.cities,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json["id"],
      name: json["name"],
      flag: json["flag"],
      cities: (json["cities"] as List)
          .map((e) => CityModel.fromJson(e))
          .toList(),
    );
  }
}
