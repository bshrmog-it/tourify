import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/restaurants/cubits/restaurants/restaurants_cubit.dart';
import 'package:tourify/features/restaurants/cubits/restaurants/restaurants_state.dart';
import 'package:tourify/features/restaurants/models/restaurant_model.dart';
import 'package:tourify/features/restaurants/screens/restaurant_details_screen.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/shared/services/location_lookup_service.dart';
import 'package:tourify/shared/widgets/retryable_network_image.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class RestaurantsListScreen extends StatelessWidget {
  const RestaurantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestaurantsCubit(
        favoritesCubit: context.read<FavoritesCubit>(),
      )..getRestaurants(),
      child: const _RestaurantsListView(),
    );
  }
}

class _RestaurantsListView extends StatefulWidget {
  const _RestaurantsListView();

  @override
  State<_RestaurantsListView> createState() => _RestaurantsListViewState();
}

class _RestaurantsListViewState extends State<_RestaurantsListView> {
  Map<int, String> _cityLabels = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    LocationLookupService.instance.getCityLabels().then((labels) {
      if (mounted) setState(() => _cityLabels = labels);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RestaurantsCubit, RestaurantsState>(
          builder: (context, state) {
            if (state is RestaurantsLoading || state is RestaurantsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RestaurantsError) {
              return _RestaurantsErrorState(message: state.message);
            }

            final all = (state as RestaurantsLoaded).restaurants;
            final q = _query.trim().toLowerCase();
            final restaurants = all.where((r) {
              if (q.isEmpty) return true;
              return r.name.toLowerCase().contains(q) ||
                  r.description.toLowerCase().contains(q) ||
                  (_cityLabels[r.cityId] ?? '').toLowerCase().contains(q);
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Restaurants',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Discover a taste worth remembering',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const WalletBadge(),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText: 'Search by restaurant or city',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () => setState(() => _query = ''),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                            filled: true,
                            fillColor: scheme.surfaceContainerHighest.withOpacity(.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.restaurant_rounded, size: 18, color: scheme.primary),
                            const SizedBox(width: 7),
                            Text(
                              '${restaurants.length} restaurants',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (restaurants.isEmpty)
                  const SliverFillRemaining(hasScrollBody: false, child: _EmptyRestaurantsState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => RestaurantCard(
                          restaurant: restaurants[index],
                          cityLabel: _cityLabels[restaurants[index].cityId],
                        ),
                        childCount: restaurants.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 14,
                        childAspectRatio: .64,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final String? cityLabel;

  const RestaurantCard({super.key, required this.restaurant, this.cityLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RestaurantDetailsScreen(restaurantId: restaurant.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  restaurant.mainImageUrl != null
                      ? RetryableNetworkImage(url: restaurant.mainImageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(Icons.restaurant_rounded, size: 44, color: scheme.onSurfaceVariant),
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  Positioned(top: 10, right: 10, child: _FavoriteButton(restaurantId: restaurant.id)),
                  if (restaurant.averageRating != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _RatingBadge(rating: restaurant.averageRating!),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 15, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(child: Text(cityLabel ?? 'Loading...', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(restaurant.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.35, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final int restaurantId;
  const _FavoriteButton({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final favorite = state.isFavorite(FavoriteType.restaurant, restaurantId);
        return Material(
          color: Colors.white.withOpacity(.93),
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.read<FavoritesCubit>().toggle(FavoriteType.restaurant, restaurantId),
            child: SizedBox(
              width: 39,
              height: 39,
              child: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 19, color: favorite ? Colors.redAccent : Colors.black87),
            ),
          ),
        );
      },
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withOpacity(.58), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _EmptyRestaurantsState extends StatelessWidget {
  const _EmptyRestaurantsState();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 78, height: 78, decoration: BoxDecoration(color: scheme.primary.withOpacity(.1), shape: BoxShape.circle),
          child: Icon(Icons.restaurant_rounded, size: 38, color: scheme.primary)),
      const SizedBox(height: 18),
      Text('No restaurants found', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      Text('Try another name or city.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
    ])));
  }
}

class _RestaurantsErrorState extends StatelessWidget {
  final String message;
  const _RestaurantsErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72, decoration: BoxDecoration(color: scheme.error.withOpacity(.1), shape: BoxShape.circle),
          child: Icon(Icons.cloud_off_rounded, size: 36, color: scheme.error)),
      const SizedBox(height: 16),
      Text('Something went wrong', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
    ])));
  }
}
