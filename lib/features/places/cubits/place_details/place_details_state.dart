import 'package:tourify/features/places/models/place_model.dart';

abstract class PlaceDetailsState {}

class PlaceDetailsInitial extends PlaceDetailsState {}

class PlaceDetailsLoading extends PlaceDetailsState {}

class PlaceDetailsLoaded extends PlaceDetailsState {
  final PlaceModel place;
  PlaceDetailsLoaded({required this.place});
}

class PlaceDetailsError extends PlaceDetailsState {
  final String message;
  PlaceDetailsError({required this.message});
}
