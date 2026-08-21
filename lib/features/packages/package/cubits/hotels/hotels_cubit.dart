import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/packages/package/cubits/hotels/hotels_state.dart';
import 'package:tourify/features/packages/package/services/get_hotels.dart';

class HotelsCubit extends Cubit<HotelsState> {
  HotelsCubit() : super(HotelsInitial());

  final GetHotels getHotelsService = GetHotels();

  Future<void> getHotels({required int countryId, required int cityId}) async {
    emit(HotelsLoading());

    try {
      final hotels = await getHotelsService.getHotels(
        countryId: countryId,
        cityId: cityId,
      );

      emit(HotelsLoaded(hotels: hotels));
    } catch (e) {
      emit(HotelsError(message: e.toString()));
    }
  }
}
