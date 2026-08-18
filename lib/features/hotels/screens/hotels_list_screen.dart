import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/shared/widgets/retryable_network_image.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/shared/services/location_lookup_service.dart';
import 'package:tourify/features/hotels/cubits/hotels/hotels_cubit.dart';
import 'package:tourify/features/hotels/cubits/hotels/hotels_state.dart';
import 'package:tourify/features/hotels/models/hotel_model.dart';
import 'package:tourify/features/hotels/screens/hotel_details_screen.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class HotelsListScreen extends StatelessWidget {
  const HotelsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HotelsCubit(favoritesCubit: context.read<FavoritesCubit>())
            ..getHotels(),
      child: const _HotelsListView(),
    );
  }
}

class _HotelsListView extends StatefulWidget {
  const _HotelsListView();

  @override
  State<_HotelsListView> createState() => _HotelsListViewState();
}

class _HotelsListViewState extends State<_HotelsListView> {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hotels',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        actions: const [WalletBadge()],
      ),
      body: BlocBuilder<HotelsCubit, HotelsState>(
        builder: (context, state) {
          // ─────────────────────────────────────────────
          // Loading
          // ─────────────────────────────────────────────

          if (state is HotelsLoading || state is HotelsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // ─────────────────────────────────────────────
          // Error
          // ─────────────────────────────────────────────

          if (state is HotelsError) {
            return _HotelsErrorState(message: state.message);
          }

          final hotels = (state as HotelsLoaded).hotels;

          // ─────────────────────────────────────────────
          // Empty
          // ─────────────────────────────────────────────

          if (hotels.isEmpty) {
            return const _EmptyHotelsState();
          }

          // ─────────────────────────────────────────────
          // Hotels Grid
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
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];

              return HotelCard(
                hotel: hotel,
                cityLabel: _cityLabels[hotel.cityId],
              );
            },
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Hotel Card
// ═════════════════════════════════════════════════════════════

class HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final String? cityLabel;

  const HotelCard({super.key, required this.hotel, this.cityLabel});

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
              builder: (_) => HotelDetailsScreen(hotelId: hotel.id),
            ),
          );
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
                  // Hotel image
                  hotel.mainImageUrl != null
                      ? RetryableNetworkImage(
                          url: hotel.mainImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.hotel_outlined,
                            size: 42,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                  // Bottom gradient
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

                  // Favorite button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _FavoriteButton(hotelId: hotel.id),
                  ),

                  // Rating badge
                  if (hotel.averageRating != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _RatingBadge(rating: hotel.averageRating!),
                    ),
                ],
              ),
            ),

            // ───────────────────────────────────────────
            // Hotel Information
            // ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Rating
                  if (hotel.averageRating != null)
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final filled = index < hotel.averageRating!.round();

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
                          hotel.averageRating!.toStringAsFixed(1),
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
  final int hotelId;

  const _FavoriteButton({required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        final isFavorite = favState.isFavorite(FavoriteType.hotel, hotelId);

        return Material(
          color: Colors.white.withOpacity(0.92),
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              context.read<FavoritesCubit>().toggle(
                FavoriteType.hotel,
                hotelId,
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

class _EmptyHotelsState extends StatelessWidget {
  const _EmptyHotelsState();

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
                Icons.hotel_outlined,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hotels found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'There are no hotels available at the moment.',
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

class _HotelsErrorState extends StatelessWidget {
  final String message;

  const _HotelsErrorState({required this.message});

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
