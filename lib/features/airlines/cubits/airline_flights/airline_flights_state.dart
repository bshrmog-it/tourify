import 'package:tourify/features/airlines/models/flight_model.dart';

sealed class AirlineFlightsState {
  const AirlineFlightsState();
}

class AirlineFlightsInitial extends AirlineFlightsState {
  const AirlineFlightsInitial();
}

class AirlineFlightsLoading extends AirlineFlightsState {
  const AirlineFlightsLoading();
}

class AirlineFlightsLoaded extends AirlineFlightsState {
  final List<FlightModel> flights;

  const AirlineFlightsLoaded(this.flights);
}

class AirlineFlightsError extends AirlineFlightsState {
  final String message;

  const AirlineFlightsError(this.message);
}
