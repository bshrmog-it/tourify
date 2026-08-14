import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/places/cubits/favorites/favorites_state.dart';
import 'package:tourify/features/places/services/place_actions_service.dart';

// مصدر حقيقة واحد لحالة المفضلة، مشترك بين شاشة القائمة وشاشة
// التفاصيل. لازم يترّجب فوق الـ Navigator (مثلاً فوق MaterialApp)
// منشان يضل نفس الكائن متاح لكل الشاشات المفتوحة عبر Navigator.push.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState({}));
  final PlaceActionsService _actionsService = PlaceActionsService();

  Future<void> toggle(int placeId) async {
    final wasFavorite = state.isFavorite(placeId);
    final updated = Set<int>.from(state.favoritePlaceIds);
    wasFavorite ? updated.remove(placeId) : updated.add(placeId);
    emit(FavoritesState(updated));

    try {
      await _actionsService.toggleFavorite(placeId);
    } catch (e) {
      // فشل الطلب بالسيرفر -> رجّع الحالة القديمة بكل الشاشات يلي عم تسمع
      final reverted = Set<int>.from(state.favoritePlaceIds);
      wasFavorite ? reverted.add(placeId) : reverted.remove(placeId);
      emit(FavoritesState(reverted));
    }
  }
}
