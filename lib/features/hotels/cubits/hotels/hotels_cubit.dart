import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/hotels/cubits/hotels/hotels_state.dart';
import 'package:tourify/features/hotels/services/get_hotels.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class HotelsCubit extends Cubit<HotelsState> {
  HotelsCubit({required this.favoritesCubit}) : super(HotelsInitial());
  final FavoritesCubit favoritesCubit;
  final GetHotels getHotelsService = GetHotels();

  Future<void> getHotels() async {
    emit(HotelsLoading());
    try {
      final hotels = await getHotelsService.getHotels();
      // نزامن حالة المفضلة الحقيقية القادمة من الـ API مع الـ Cubit المشترك
      favoritesCubit.syncFromServer(
        FavoriteType.hotel,
        {for (final h in hotels) h.id: h.isFavorite},
      );
      emit(HotelsLoaded(hotels: hotels));
    } catch (e) {
      emit(HotelsError(message: e.toString()));
    }
  }
}
