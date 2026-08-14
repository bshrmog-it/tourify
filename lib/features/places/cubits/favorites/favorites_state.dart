class FavoritesState {
  final Set<int> favoritePlaceIds;
  const FavoritesState(this.favoritePlaceIds);

  bool isFavorite(int placeId) => favoritePlaceIds.contains(placeId);
}
