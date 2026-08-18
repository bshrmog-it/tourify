import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/airlines/services/airlines_booking_service.dart';
import 'flight_booking_state.dart';

class FlightBookingCubit extends Cubit<FlightBookingState> {
  FlightBookingCubit({AirlinesBookingService? service})
      : _service = service ?? AirlinesBookingService(),
        super(const FlightBookingInitial());

  final AirlinesBookingService _service;

  Future<void> book(int scheduleId) async {
    emit(const FlightBookingLoading());

    try {
      final booking = await _service.bookFlightSchedule(scheduleId);
      emit(FlightBookingSuccess(booking));
    } catch (e) {
      emit(FlightBookingError(_extractMessage(e)));
    }
  }

  String _extractMessage(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');

    // ApiService implementations differ. Keep the backend message intact
    // when it is already exposed by the thrown error.
    if (text.contains('"message"')) {
      final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(text);
      if (match != null) return match.group(1)!;
    }

    return text;
  }
}
