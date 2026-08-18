// cubit/my_bookings_state.dart
import '../models/booking_group.dart';

abstract class MyBookingsState {}

class MyBookingsInitial extends MyBookingsState {}

class MyBookingsLoading extends MyBookingsState {}

class MyBookingsLoaded extends MyBookingsState {
  final GroupedBookings grouped;
  MyBookingsLoaded(this.grouped);
}

class MyBookingsError extends MyBookingsState {
  final String message;
  MyBookingsError(this.message);
}
