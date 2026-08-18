import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/hotels/cubits/hotel_details/hotel_details_state.dart';
import 'package:tourify/features/hotels/services/get_hotel_details.dart';
import 'package:tourify/features/hotels/services/hotel_actions_service.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class HotelDetailsCubit extends Cubit<HotelDetailsState> {
  HotelDetailsCubit({required this.favoritesCubit}) : super(HotelDetailsInitial());
  final FavoritesCubit favoritesCubit;
  final GetHotelDetails getHotelDetailsService = GetHotelDetails();
  final HotelActionsService actionsService = HotelActionsService();

  Future<void> getHotelDetails(int id) async {
    emit(HotelDetailsLoading());
    try {
      final hotel = await getHotelDetailsService.getHotelDetails(id);
      favoritesCubit.syncFromServer(FavoriteType.hotel, {hotel.id: hotel.isFavorite});
      emit(HotelDetailsLoaded(hotel: hotel));
    } catch (e) {
      emit(HotelDetailsError(message: e.toString()));
    }
  }

  Future<void> rateHotel(int hotelId, int rating) async {
    await actionsService.rateHotel(hotelId, rating);
  }
}
