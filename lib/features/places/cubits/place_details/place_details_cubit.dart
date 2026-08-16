import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/places/cubits/place_details/place_details_state.dart';
import 'package:tourify/features/places/services/get_place_details.dart';
import 'package:tourify/features/places/services/place_actions_service.dart';

class PlaceDetailsCubit extends Cubit<PlaceDetailsState> {
  PlaceDetailsCubit() : super(PlaceDetailsInitial());
  final GetPlaceDetails getPlaceDetailsService = GetPlaceDetails();
  final PlaceActionsService actionsService = PlaceActionsService();

  Future<void> getPlaceDetails(int id) async {
    emit(PlaceDetailsLoading());
    try {
      final place = await getPlaceDetailsService.getPlaceDetails(id);
      emit(PlaceDetailsLoaded(place: place));
    } catch (e) {
      emit(PlaceDetailsError(message: e.toString()));
    }
  }

  Future<void> ratePlace(int placeId, int rating) async {
    await actionsService.ratePlace(placeId, rating);
  }
}
