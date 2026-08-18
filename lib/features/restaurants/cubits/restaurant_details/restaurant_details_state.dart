import 'package:tourify/features/restaurants/models/restaurant_model.dart';

abstract class RestaurantDetailsState {}

class RestaurantDetailsInitial extends RestaurantDetailsState {}

class RestaurantDetailsLoading extends RestaurantDetailsState {}

class RestaurantDetailsLoaded extends RestaurantDetailsState {
  final RestaurantModel restaurant;

  RestaurantDetailsLoaded({required this.restaurant});
}

class RestaurantDetailsError extends RestaurantDetailsState {
  final String message;

  RestaurantDetailsError({required this.message});
}
