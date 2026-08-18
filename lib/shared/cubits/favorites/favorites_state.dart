enum FavoriteType { place, hotel, restaurant, airline }

class FavoritesState {
  final Map<FavoriteType, Set<int>> favorites;
  const FavoritesState(this.favorites);

  bool isFavorite(FavoriteType type, int id) =>
      favorites[type]?.contains(id) ?? false;
}
