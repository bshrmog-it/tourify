import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/get_flights_dropdown_service.dart';
import 'flights_dropdown_state.dart';

class FlightsDropdownCubit extends Cubit<FlightsDropdownState> {
  final GetFlightsDropdownService _service = GetFlightsDropdownService();

  FlightsDropdownCubit() : super(FlightsDropdownInitial());

  Future<void> loadFlights() async {
    emit(FlightsDropdownLoading());
    try {
      final flights = await _service.getFlights();
      emit(FlightsDropdownLoaded(flights));
    } catch (e) {
      emit(FlightsDropdownError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
