import '../models/dropdown_flight_model.dart';

abstract class FlightsDropdownState {}

class FlightsDropdownInitial extends FlightsDropdownState {}

class FlightsDropdownLoading extends FlightsDropdownState {}

class FlightsDropdownLoaded extends FlightsDropdownState {
  final List<DropdownFlightModel> flights;
  FlightsDropdownLoaded(this.flights);
}

class FlightsDropdownError extends FlightsDropdownState {
  final String message;
  FlightsDropdownError(this.message);
}
