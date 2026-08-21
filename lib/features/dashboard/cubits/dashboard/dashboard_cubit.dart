import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/dashboard/cubits/dashboard/dashboard_state.dart';
import 'package:tourify/features/dashboard/services/get_dashboard.dart';
import 'package:tourify/features/dashboard/services/get_dashboard_favorites.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required this.favoritesCubit}) : super(DashboardInitial());
  final FavoritesCubit favoritesCubit;
  final GetDashboard _service = GetDashboard();
  final GetDashboardFavorites _favoritesService = GetDashboardFavorites();

  Future<void> load({String? country}) async {
    emit(DashboardLoading());
    try {
      final data = await _service.getDashboard(country: country);

      // ⚠️ عناصر preview بالداشبورد (places/hotels/restaurants/agencies)
      // ما فيهم is_favorite موثوق (غير موجود أو دايماً false)، فما
      // بنعتمد عليهم لمزامنة المفضلة. بدل هيك، منجيب المصدر الموثوق
      // الوحيد: /api/dashboard/favorites، وبس هاد يلي بيحدد الحالة.
      try {
        final favorites = await _favoritesService.getFavorites();
        favoritesCubit.syncFromServer(
          FavoriteType.place,
          {for (final p in favorites.places) p.id: true},
        );
        favoritesCubit.syncFromServer(
          FavoriteType.hotel,
          {for (final h in favorites.hotels) h.id: true},
        );
        favoritesCubit.syncFromServer(
          FavoriteType.restaurant,
          {for (final r in favorites.restaurants) r.id: true},
        );
      } catch (_) {
        // فشل جلب المفضلة ما لازم يوقف تحميل الداشبورد كامل
      }

      emit(DashboardLoaded(data: data, selectedCountry: country));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}
