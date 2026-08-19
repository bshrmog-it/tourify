import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/cubits/flights/flights_state.dart';
import 'package:tourify/features/agency/create_package/services/get_airlines.dart';

class FlightsCubit extends Cubit<FlightsState> {
  FlightsCubit() : super(FlightsInitial());

  final GetAirlines getAirlinesService = GetAirlines();

  Future<void> getFlights({required int countryId, required int cityId}) async {
    emit(FlightsLoading());

    try {
      final airlines = await getAirlinesService.getAirlines(
        countryId: countryId,
        cityId: cityId,
      );

      emit(FlightsLoaded(airlines: airlines));
    } catch (e) {
      emit(FlightsError(message: e.toString()));
    }
  }
}
