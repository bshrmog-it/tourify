import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/airlines/services/airlines_service.dart';
import 'flight_schedules_state.dart';

class FlightSchedulesCubit extends Cubit<FlightSchedulesState> {
  FlightSchedulesCubit({AirlinesService? service})
      : _service = service ?? AirlinesService(),
        super(const FlightSchedulesInitial());

  final AirlinesService _service;

  Future<void> getSchedules(int flightId) async {
    emit(const FlightSchedulesLoading());

    try {
      final schedules = await _service.getSchedules(flightId);
      emit(FlightSchedulesLoaded(schedules));
    } catch (e) {
      emit(FlightSchedulesError(e.toString()));
    }
  }
}
