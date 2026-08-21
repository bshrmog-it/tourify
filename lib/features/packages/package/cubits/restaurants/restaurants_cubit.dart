import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/packages/package/cubits/restaurants/restaurants_state.dart';
import 'package:tourify/features/packages/package/services/get_resturents.dart';

class RestaurantsCubit extends Cubit<RestaurantsState> {
  RestaurantsCubit() : super(RestaurantsInitial());

  final GetRestaurants getRestaurantsService = GetRestaurants();

  Future<void> getRestaurants({
    required int countryId,
    required int cityId,
  }) async {
    emit(RestaurantsLoading());

    try {
      final restaurants = await getRestaurantsService.getRestaurants(
        countryId: countryId,
        cityId: cityId,
      );

      emit(RestaurantsLoaded(restaurants: restaurants));
    } catch (e) {
      emit(RestaurantsError(message: e.toString()));
    }
  }
}
