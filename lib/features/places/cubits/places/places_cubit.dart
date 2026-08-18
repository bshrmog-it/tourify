import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/places/cubits/places/places_state.dart';
import 'package:tourify/features/places/services/get_places.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class PlacesCubit extends Cubit<PlacesState> {
  PlacesCubit({required this.favoritesCubit}) : super(PlacesInitial());
  final FavoritesCubit favoritesCubit;
  final GetPlaces getPlacesService = GetPlaces();

  Future<void> getPlaces() async {
    emit(PlacesLoading());
    try {
      final places = await getPlacesService.getPlaces();
      // نزامن حالة المفضلة الحقيقية القادمة من الـ API مع الـ Cubit المشترك
      favoritesCubit.syncFromServer(
        FavoriteType.place,
        {for (final p in places) p.id: p.isFavorite},
      );
      emit(PlacesLoaded(places: places));
    } catch (e) {
      emit(PlacesError(message: e.toString()));
    }
  }
}
