import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/places/cubits/places/places_state.dart';
import 'package:tourify/features/places/services/get_places.dart';

class PlacesCubit extends Cubit<PlacesState> {
  PlacesCubit() : super(PlacesInitial());
  final GetPlaces getPlacesService = GetPlaces();

  Future<void> getPlaces() async {
    emit(PlacesLoading());
    try {
      final places = await getPlacesService.getPlaces();
      emit(PlacesLoaded(places: places));
    } catch (e) {
      emit(PlacesError(message: e.toString()));
    }
  }
}
