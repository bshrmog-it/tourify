import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/create_flight_schedule_service.dart';
import 'create_schedule_state.dart';

class CreateScheduleCubit extends Cubit<CreateScheduleState> {
  final CreateFlightScheduleService _service = CreateFlightScheduleService();

  CreateScheduleCubit() : super(CreateScheduleInitial());

  Future<void> createSchedule({
    required int flightId,
    required String departureTime,
    required String arrivalTime,
    required String startDate,
    required int weeks,
    required List<int> daysOfWeek,
  }) async {
    emit(CreateScheduleLoading());
    try {
      await _service.createSchedule(
        flightId: flightId,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        startDate: startDate,
        weeks: weeks,
        daysOfWeek: daysOfWeek,
      );
      emit(CreateScheduleSuccess());
    } catch (e) {
      emit(CreateScheduleError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
