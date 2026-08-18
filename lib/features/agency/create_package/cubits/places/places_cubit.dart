import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/cubits/places/places_state.dart';
import 'package:tourify/features/agency/create_package/services/get_place.dart';

class PlacesCubit extends Cubit<PlacesState> {
  PlacesCubit() : super(PlacesInitial());

  final GetPlaces getPlacesService = GetPlaces();

  Future<void> getPlaces({required int countryId, required int cityId}) async {
    emit(PlacesLoading());

    try {
      final places = await getPlacesService.getPlaces(
        countryId: countryId,
        cityId: cityId,
      );

      emit(PlacesLoaded(places: places));
    } catch (e) {
      emit(PlacesError(message: e.toString()));
    }
  }
}
