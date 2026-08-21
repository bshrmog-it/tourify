import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/agency_view/screens/agency_details_screen.dart';
import 'package:tourify/features/dashboard/cubits/favorites_screen/favorites_screen_cubit.dart';
import 'package:tourify/features/dashboard/cubits/favorites_screen/favorites_screen_state.dart';
import 'package:tourify/features/dashboard/widgets/dashboard_widgets.dart';
import 'package:tourify/features/places/screens/place_details_screen.dart';
import 'package:tourify/features/hotels/screens/hotel_details_screen.dart';
import 'package:tourify/features/restaurants/screens/restaurant_details_screen.dart';
import 'package:tourify/features/airlines/screens/airline_flights_screen.dart';

import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            title: title,
            icon: icon,
          ),
          Wrap(
            spacing: 12,
            runSpacing: 18,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 46,
                color: colorScheme.primary.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No favorites yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Save places, hotels, restaurants and more to find them here later.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (_) => FavoritesScreenCubit()..load(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          titleSpacing: 16,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Favorites',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),

        // بيسمع لأي تغيير بحالة المفضلة المشتركة
        // وبيعيد تحميل الشاشة تلقائياً.
        body: BlocListener<FavoritesCubit, FavoritesState>(
          listener: (context, _) {
            context.read<FavoritesScreenCubit>().load();
          },
          child: BlocBuilder<FavoritesScreenCubit, FavoritesScreenState>(
            builder: (context, state) {
              if (state is FavoritesScreenLoading ||
                  state is FavoritesScreenInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is FavoritesScreenError) {
                return _buildErrorState(
                  context,
                  state.message,
                );
              }

              final favorites =
                  (state as FavoritesScreenLoaded).favorites;

              final isEmpty =
                  favorites.places.isEmpty &&
                  favorites.hotels.isEmpty &&
                  favorites.restaurants.isEmpty;

              if (isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  30,
                ),
                children: [
                  if (favorites.places.isNotEmpty)
                    _buildFavoritesSection(
                      context: context,
                      title: 'Tourist Places',
                      icon: Icons.landscape_outlined,
                      children: favorites.places
                          .map(
                            (p) => DashboardPreviewCard(
                              imageUrl: p.mainImageUrl,
                              title: p.name,
                              rating: p.averageRating,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlaceDetailsScreen(
                                    placeId: p.id,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  if (favorites.hotels.isNotEmpty)
                    _buildFavoritesSection(
                      context: context,
                      title: 'Hotels',
                      icon: Icons.hotel_outlined,
                      children: favorites.hotels
                          .map(
                            (h) => DashboardPreviewCard(
                              imageUrl: h.mainImageUrl,
                              title: h.name,
                              rating: h.averageRating,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HotelDetailsScreen(
                                    hotelId: h.id,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  if (favorites.restaurants.isNotEmpty)
                    _buildFavoritesSection(
                      context: context,
                      title: 'Restaurants',
                      icon: Icons.restaurant_outlined,
                      children: favorites.restaurants
                          .map(
                            (r) => DashboardPreviewCard(
                              imageUrl: r.mainImageUrl,
                              title: r.name,
                              rating: r.averageRating,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RestaurantDetailsScreen(
                                    restaurantId: r.id,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  if (favorites.agencies.isNotEmpty)
                    _buildFavoritesSection(
                      context: context,
                      title: 'Travel Offices',
                      icon: Icons.business_outlined,
                      children: favorites.agencies
                          .map(
                            (a) => DashboardPreviewCard(
                              imageUrl: a.mainImageUrl,
                              title: a.name,
                              rating: a.averageRating,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AgencyDetailsScreen(
                                    agencyId: a.id,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  if (favorites.airlines.isNotEmpty)
                    _buildFavoritesSection(
                      context: context,
                      title: 'Airlines',
                      icon: Icons.flight_outlined,
                      children: favorites.airlines
                          .map(
                            (a) => DashboardPreviewCard(
                              imageUrl: null,
                              title: a.name,
                              rating: a.averageRating,
                              fallbackIcon:
                                  Icons.flight_takeoff_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AirlineFlightsScreen(
                                    airline: a,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}