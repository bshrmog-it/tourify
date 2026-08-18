import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/restaurants/cubits/restaurant_details/restaurant_details_state.dart';
import 'package:tourify/features/restaurants/services/get_restaurant_details.dart';
import 'package:tourify/features/restaurants/services/restaurant_actions_service.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class RestaurantDetailsCubit extends Cubit<RestaurantDetailsState> {
  RestaurantDetailsCubit({required this.favoritesCubit})
      : super(RestaurantDetailsInitial());

  final FavoritesCubit favoritesCubit;
  final GetRestaurantDetails getRestaurantDetailsService =
      GetRestaurantDetails();
  final RestaurantActionsService actionsService = RestaurantActionsService();

  Future<void> getRestaurantDetails(int id) async {
    emit(RestaurantDetailsLoading());

    try {
      final restaurant =
          await getRestaurantDetailsService.getRestaurantDetails(id);

      favoritesCubit.syncFromServer(
        FavoriteType.restaurant,
        {restaurant.id: restaurant.isFavorite},
      );

      emit(RestaurantDetailsLoaded(restaurant: restaurant));
    } catch (e) {
      emit(RestaurantDetailsError(message: e.toString()));
    }
  }

  Future<void> rateRestaurant(int restaurantId, int rating) async {
    await actionsService.rateRestaurant(restaurantId, rating);
  }
}
