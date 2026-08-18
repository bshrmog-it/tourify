import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/restaurants/cubits/restaurants/restaurants_state.dart';
import 'package:tourify/features/restaurants/services/get_restaurants.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class RestaurantsCubit extends Cubit<RestaurantsState> {
  RestaurantsCubit({required this.favoritesCubit})
      : super(RestaurantsInitial());

  final FavoritesCubit favoritesCubit;
  final GetRestaurants getRestaurantsService = GetRestaurants();

  Future<void> getRestaurants() async {
    emit(RestaurantsLoading());

    try {
      final restaurants = await getRestaurantsService.getRestaurants();

      favoritesCubit.syncFromServer(
        FavoriteType.restaurant,
        {for (final r in restaurants) r.id: r.isFavorite},
      );

      emit(RestaurantsLoaded(restaurants: restaurants));
    } catch (e) {
      emit(RestaurantsError(message: e.toString()));
    }
  }
}
