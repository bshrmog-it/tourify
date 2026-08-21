import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/dashboard/cubits/favorites_screen/favorites_screen_state.dart';
import 'package:tourify/features/dashboard/services/get_dashboard_favorites.dart';

class FavoritesScreenCubit extends Cubit<FavoritesScreenState> {
  FavoritesScreenCubit() : super(FavoritesScreenInitial());
  final GetDashboardFavorites _service = GetDashboardFavorites();

  Future<void> load() async {
    emit(FavoritesScreenLoading());
    try {
      final favorites = await _service.getFavorites();
      emit(FavoritesScreenLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoritesScreenError(message: e.toString()));
    }
  }
}
