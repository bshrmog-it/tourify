import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

// مصدر حقيقة واحد لحالة المفضلة، مشترك بين كل الأقسام (Places, Hotels,
// Restaurants, Airlines...). لازم يترّجب فوق الـ Navigator (مثلاً فوق
// MaterialApp) منشان يضل نفس الكائن متاح لكل الشاشات المفتوحة.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState({}));
  final ApiService _apiService = ApiService();

  String _segmentFor(FavoriteType type) {
    switch (type) {
      case FavoriteType.place:
        return 'places';
      case FavoriteType.hotel:
        return 'hotels';
      case FavoriteType.restaurant:
        return 'restaurants';
      case FavoriteType.airline:
        return 'airlines';
    }
  }

  Future<void> toggle(FavoriteType type, int id) async {
    final previousState = state;
    final wasFavorite = previousState.isFavorite(type, id);

    final updated = {
      for (final entry in previousState.favorites.entries)
        entry.key: Set<int>.from(entry.value),
    };
    final currentSet = updated.putIfAbsent(type, () => <int>{});
    wasFavorite ? currentSet.remove(id) : currentSet.add(id);
    emit(FavoritesState(updated));

    try {
      await _apiService.post('/${_segmentFor(type)}/$id/favorite', data: {});
    } catch (e) {
      // فشل الطلب بالسيرفر -> رجّع الحالة يلي كانت قبل الضغطة تماماً
      emit(previousState);
    }
  }
  // مزامنة (مش تبديل) — بتاخد الحالة الحقيقية من رد الـ API وتحطها
// مباشرة بدون ما تنادي أي endpoint.
void syncFromServer(FavoriteType type, Map<int, bool> serverFavorites) {
  final updated = {
    for (final entry in state.favorites.entries)
      entry.key: Set<int>.from(entry.value),
  };
  final currentSet = updated.putIfAbsent(type, () => <int>{});
  serverFavorites.forEach((id, isFav) {
    isFav ? currentSet.add(id) : currentSet.remove(id);
  });
  emit(FavoritesState(updated));
}
}
