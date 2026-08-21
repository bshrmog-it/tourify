abstract class CreateScheduleState {}

class CreateScheduleInitial extends CreateScheduleState {}

class CreateScheduleLoading extends CreateScheduleState {}

class CreateScheduleSuccess extends CreateScheduleState {}

class CreateScheduleError extends CreateScheduleState {
  final String message;
  CreateScheduleError(this.message);
}
