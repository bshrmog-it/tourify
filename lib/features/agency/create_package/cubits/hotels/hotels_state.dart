import 'package:tourify/features/agency/create_package/models/hotel_model.dart';

abstract class HotelsState {}

class HotelsInitial extends HotelsState {}

class HotelsLoading extends HotelsState {}

class HotelsLoaded extends HotelsState {
  final List<HotelModel> hotels;

  HotelsLoaded({required this.hotels});
}

class HotelsError extends HotelsState {
  final String message;

  HotelsError({required this.message});
}
