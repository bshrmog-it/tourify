import 'package:tourify/features/airlines/models/flight_schedule_model.dart';

sealed class FlightSchedulesState {
  const FlightSchedulesState();
}

class FlightSchedulesInitial extends FlightSchedulesState {
  const FlightSchedulesInitial();
}

class FlightSchedulesLoading extends FlightSchedulesState {
  const FlightSchedulesLoading();
}

class FlightSchedulesLoaded extends FlightSchedulesState {
  final List<FlightScheduleModel> schedules;

  const FlightSchedulesLoaded(this.schedules);
}

class FlightSchedulesError extends FlightSchedulesState {
  final String message;

  const FlightSchedulesError(this.message);
}
