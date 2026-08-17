import 'package:tourify/features/restaurants/models/restaurant_model.dart';

abstract class RestaurantsState {}

class RestaurantsInitial extends RestaurantsState {}

class RestaurantsLoading extends RestaurantsState {}

class RestaurantsLoaded extends RestaurantsState {
  final List<RestaurantModel> restaurants;

  RestaurantsLoaded({required this.restaurants});
}

class RestaurantsError extends RestaurantsState {
  final String message;

  RestaurantsError({required this.message});
}
