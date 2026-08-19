// cubit/my_bookings_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/my_bookings_service.dart';
import 'my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final MyBookingsService _service = MyBookingsService();

  MyBookingsCubit() : super(MyBookingsInitial());

  Future<void> load() async {
    emit(MyBookingsLoading());
    try {
      final grouped = await _service.getMyBookings();
      emit(MyBookingsLoaded(grouped));
    } catch (e) {
      emit(MyBookingsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> cancelPackage(int packageId, int bookingId) async {
    await _service.cancelPackageBooking(
      packageId: packageId,
      bookingId: bookingId,
    );
    await load(); // بعد النجاح فقط، نعيد تحميل القائمة
  }
}
