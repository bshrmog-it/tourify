import '../../models/country_model.dart';

abstract class CountriesState {}

class CountriesInitial extends CountriesState {}

class CountriesLoading extends CountriesState {}

class CountriesLoaded extends CountriesState {
  final List<CountryModel> countries;

  CountriesLoaded(this.countries);
}

class CountriesError extends CountriesState {
  final String message;

  CountriesError(this.message);
}