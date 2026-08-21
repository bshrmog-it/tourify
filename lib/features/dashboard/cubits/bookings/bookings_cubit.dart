import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/dashboard/cubits/bookings/bookings_state.dart';
import 'package:tourify/features/dashboard/services/get_dashboard_bookings.dart';

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit() : super(BookingsInitial());
  final GetDashboardBookings _service = GetDashboardBookings();

  Future<void> load() async {
    emit(BookingsLoading());
    try {
      final bookings = await _service.getBookings();
      emit(BookingsLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingsError(message: e.toString()));
    }
  }
}
