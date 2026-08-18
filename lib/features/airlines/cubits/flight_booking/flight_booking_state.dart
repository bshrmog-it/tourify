import 'package:tourify/features/airlines/models/flight_booking_model.dart';

sealed class FlightBookingState {
  const FlightBookingState();
}

class FlightBookingInitial extends FlightBookingState {
  const FlightBookingInitial();
}

class FlightBookingLoading extends FlightBookingState {
  const FlightBookingLoading();
}

class FlightBookingSuccess extends FlightBookingState {
  final FlightBookingModel booking;

  const FlightBookingSuccess(this.booking);
}

class FlightBookingError extends FlightBookingState {
  final String message;

  const FlightBookingError(this.message);
}
