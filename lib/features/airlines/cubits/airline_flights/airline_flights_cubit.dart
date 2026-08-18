import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/airlines/services/airlines_service.dart';
import 'airline_flights_state.dart';

class AirlineFlightsCubit extends Cubit<AirlineFlightsState> {
  AirlineFlightsCubit({AirlinesService? service})
      : _service = service ?? AirlinesService(),
        super(const AirlineFlightsInitial());

  final AirlinesService _service;

  Future<void> getFlights(int airlineId) async {
    emit(const AirlineFlightsLoading());

    try {
      final flights = await _service.getFlights(airlineId);
      emit(AirlineFlightsLoaded(flights));
    } catch (e) {
      emit(AirlineFlightsError(e.toString()));
    }
  }
}
