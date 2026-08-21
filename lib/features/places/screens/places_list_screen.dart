import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/shared/widgets/retryable_network_image.dart';
import 'package:tourify/features/places/cubits/places/places_cubit.dart';
import 'package:tourify/features/places/cubits/places/places_state.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/features/places/models/place_model.dart';
import 'package:tourify/shared/services/location_lookup_service.dart';
import 'package:tourify/features/places/screens/place_details_screen.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlacesCubit(favoritesCubit: context.read<FavoritesCubit>())..getPlaces(),
      child: const _PlacesListView(),
    );
  }
}

class _PlacesListView extends StatefulWidget {
  const _PlacesListView();

  @override
  State<_PlacesListView> createState() => _PlacesListViewState();
}

class _PlacesListViewState extends State<_PlacesListView> {
  Map<int, String> _cityLabels = {};

  @override
  void initState() {
    super.initState();

    LocationLookupService.instance.getCityLabels().then((labels) {
      if (mounted) {
        setState(() {
          _cityLabels = labels;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tourist attractions ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        actions: const [WalletBadge()],
      ),
      body: BlocBuilder<PlacesCubit, PlacesState>(
        builder: (context, state) {
          // ─────────────────────────────────────────────
          // Loading
          // ─────────────────────────────────────────────

          if (state is PlacesLoading || state is PlacesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // ─────────────────────────────────────────────
          // Error
          // ─────────────────────────────────────────────

          if (state is PlacesError) {
            return _PlacesErrorState(message: state.message);
          }

          final places = (state as PlacesLoaded).places;

          // ─────────────────────────────────────────────
          // Empty
          // ─────────────────────────────────────────────

          if (places.isEmpty) {
            return const _EmptyPlacesState();
          }

          // ─────────────────────────────────────────────
          // Places Grid
          // ─────────────────────────────────────────────

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 14,
              childAspectRatio: 0.67,
            ),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];

              return PlaceCard(
                place: place,
                cityLabel: _cityLabels[place.cityId],
              );
            },
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Place Card
// ═════════════════════════════════════════════════════════════

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final String? cityLabel;

  const PlaceCard({super.key, required this.place, this.cityLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailsScreen(placeId: place.id),
            ),
          ).then((_) => context.read<PlacesCubit>().getPlaces());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────────────────────────────────────────
            // Image
            // ───────────────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main image
                  place.mainImageUrl != null
                      ? RetryableNetworkImage(
                          url: place.mainImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.place_outlined,
                            size: 42,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                  // Gradient
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0.45, 0.65, 1.0],
                      ),
                    ),
                  ),

                  // Favorite
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _FavoriteButton(placeId: place.id),
                  ),

                  // Rating
                  if (place.averageRating != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _RatingBadge(rating: place.averageRating!),
                    ),
                ],
              ),
            ),

            // ───────────────────────────────────────────
            // Place information
            // ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Rating
                  if (place.averageRating != null)
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final filled = index < place.averageRating!.round();

                          return Icon(
                            filled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 15,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 5),
                        Text(
                          place.averageRating!.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'No ratings yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cityLabel ?? 'Loading...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Favorite Button
// ═════════════════════════════════════════════════════════════

class _FavoriteButton extends StatelessWidget {
  final int placeId;

  const _FavoriteButton({required this.placeId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        final isFavorite = favState.isFavorite(FavoriteType.place, placeId);

        return Material(
          color: Colors.white.withOpacity(0.92),
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              context.read<FavoritesCubit>().toggle(
                FavoriteType.place,
                placeId,
              );
            },
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 19,
                color: isFavorite ? Colors.redAccent : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Rating Badge
// ═════════════════════════════════════════════════════════════

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Empty State
// ═════════════════════════════════════════════════════════════

class _EmptyPlacesState extends StatelessWidget {
  const _EmptyPlacesState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.explore_outlined,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No places found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'There are no tourist places available at the moment.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Error State
// ═════════════════════════════════════════════════════════════

class _PlacesErrorState extends StatelessWidget {
  final String message;

  const _PlacesErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
