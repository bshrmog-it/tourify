abstract class HotelBookingState {}

class HotelBookingIdle extends HotelBookingState {}

class HotelBookingInProgress extends HotelBookingState {}

class HotelBookingSuccess extends HotelBookingState {
  final Map<String, dynamic> booking;
  HotelBookingSuccess(this.booking);
}

class HotelBookingFailure extends HotelBookingState {
  final String message;
  HotelBookingFailure(this.message);
}
