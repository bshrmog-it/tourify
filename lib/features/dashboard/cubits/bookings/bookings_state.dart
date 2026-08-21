import 'package:tourify/features/dashboard/models/booking_model.dart';

abstract class BookingsState {}

class BookingsInitial extends BookingsState {}

class BookingsLoading extends BookingsState {}

class BookingsLoaded extends BookingsState {
  final List<BookingModel> bookings;
  BookingsLoaded({required this.bookings});
}

class BookingsError extends BookingsState {
  final String message;
  BookingsError({required this.message});
}
