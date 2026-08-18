import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/hotels/cubits/hotel_booking/hotel_booking_state.dart';
import 'package:tourify/features/hotels/models/hotel_model.dart';
import 'package:tourify/features/hotels/services/hotel_booking_service.dart';

class HotelBookingCubit extends Cubit<HotelBookingState> {
  HotelBookingCubit() : super(HotelBookingIdle());
  final HotelBookingService _service = HotelBookingService();

  Future<void> book({
    required List<HotelRoom> roomsOfType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(HotelBookingInProgress());
    try {
      final booking = await _service.bookAvailableRoom(
        roomIds: roomsOfType.map((r) => r.id).toList(),
        startDate: startDate,
        endDate: endDate,
      );
      emit(HotelBookingSuccess(booking));
    } catch (e) {
      emit(HotelBookingFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() => emit(HotelBookingIdle());
}
