import 'package:tourify/features/dashboard/services/get_dashboard_favorites.dart';

abstract class FavoritesScreenState {}

class FavoritesScreenInitial extends FavoritesScreenState {}

class FavoritesScreenLoading extends FavoritesScreenState {}

class FavoritesScreenLoaded extends FavoritesScreenState {
  final DashboardFavorites favorites;
  FavoritesScreenLoaded({required this.favorites});
}

class FavoritesScreenError extends FavoritesScreenState {
  final String message;
  FavoritesScreenError({required this.message});
}
