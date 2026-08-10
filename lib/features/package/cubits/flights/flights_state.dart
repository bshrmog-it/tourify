import 'package:tourify/features/package/models/airline_model.dart';

abstract class FlightsState {}

class FlightsInitial extends FlightsState {}

class FlightsLoading extends FlightsState {}

class FlightsLoaded extends FlightsState {
  final List<AirlineModel> airlines;

  FlightsLoaded({required this.airlines});
}

class FlightsError extends FlightsState {
  final String message;

  FlightsError({required this.message});
}
