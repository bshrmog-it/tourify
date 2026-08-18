import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/hotels/widgets/room_booking_section.dart';
import 'package:tourify/shared/widgets/retryable_network_image.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/features/hotels/cubits/hotel_details/hotel_details_cubit.dart';
import 'package:tourify/features/hotels/cubits/hotel_details/hotel_details_state.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class HotelDetailsScreen extends StatelessWidget {
  final int hotelId;

  const HotelDetailsScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HotelDetailsCubit(favoritesCubit: context.read<FavoritesCubit>())
            ..getHotelDetails(hotelId),
      child: _HotelDetailsView(hotelId: hotelId),
    );
  }
}

class _HotelDetailsView extends StatefulWidget {
  final int hotelId;

  const _HotelDetailsView({required this.hotelId});

  @override
  State<_HotelDetailsView> createState() => _HotelDetailsViewState();
}

class _HotelDetailsViewState extends State<_HotelDetailsView> {
  String? _selectedImageUrl;
  int? _userRating;
  bool _submittingRating = false;

  Future<void> _submitRating(int rating) async {
    setState(() {
      _userRating = rating;
      _submittingRating = true;
    });

    try {
      await context.read<HotelDetailsCubit>().rateHotel(widget.hotelId, rating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your rating!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('We could not submit your rating. Please try again.'),
          ),
        );

        setState(() => _userRating = null);
      }
    } finally {
      if (mounted) {
        setState(() => _submittingRating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<HotelDetailsCubit, HotelDetailsState>(
        builder: (context, state) {
          if (state is HotelDetailsLoading || state is HotelDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotelDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          }

          final loaded = state as HotelDetailsLoaded;
          final hotel = loaded.hotel;

          final heroImageUrl = _selectedImageUrl ?? hotel.mainImageUrl;

          final averageRating = hotel.averageRating;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─────────────────────────────────────────────
              // Hero Image
              // ─────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: colorScheme.surface,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      heroImageUrl != null
                          ? RetryableNetworkImage(
                              url: heroImageUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.hotel_outlined,
                                size: 64,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),

                      // Dark gradient for better readability.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.75),
                            ],
                            stops: const [0.45, 0.65, 1.0],
                          ),
                        ),
                      ),

                      // Hotel information over the image.
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(blurRadius: 8, color: Colors.black54),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _RatingSummary(rating: averageRating),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  const Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: WalletBadge(),
                  ),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favState) {
                      final isFavorite = favState.isFavorite(
                        FavoriteType.hotel,
                        hotel.id,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: Colors.black.withOpacity(0.35),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: isFavorite
                                ? 'Remove from favorites'
                                : 'Add to favorites',
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : Colors.white,
                            ),
                            onPressed: () {
                              context.read<FavoritesCubit>().toggle(
                                FavoriteType.hotel,
                                hotel.id,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // ─────────────────────────────────────────────
              // Content
              // ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ───────────────────────────────────
                      // Contact Information
                      // ───────────────────────────────────
                      _InfoCard(
                        icon: Icons.phone_outlined,
                        title: 'Contact',
                        value: hotel.phone,
                      ),

                      const SizedBox(height: 24),

                      // ───────────────────────────────────
                      // Description
                      // ───────────────────────────────────
                      _SectionTitle(
                        icon: Icons.info_outline,
                        title: 'About this hotel',
                      ),

                      const SizedBox(height: 10),

                      Text(
                        hotel.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ───────────────────────────────────
                      // Photos
                      // ───────────────────────────────────
                      _SectionTitle(
                        icon: Icons.photo_library_outlined,
                        title: 'Photos',
                        trailing: hotel.images.isNotEmpty
                            ? Text(
                                '${hotel.images.length} photos',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(height: 12),

                      if (hotel.images.isEmpty)
                        _EmptyGallery()
                      else
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: hotel.images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final imageUrl = hotel.images[index].fullUrl;

                              final isSelected = heroImageUrl == imageUrl;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImageUrl = imageUrl;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 96,
                                  height: 96,
                                  padding: EdgeInsets.all(isSelected ? 3 : 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: isSelected
                                        ? Border.all(
                                            color: colorScheme.primary,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      isSelected ? 10 : 14,
                                    ),
                                    child: RetryableNetworkImage(
                                      url: imageUrl,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 30),

                      // ───────────────────────────────────
                      // Room Booking
                      // ───────────────────────────────────
                      _SectionTitle(
                        icon: Icons.bed_outlined,
                        title: 'Book a room',
                      ),

                      const SizedBox(height: 12),

                      RoomBookingSection(roomsByType: hotel.roomsByType),

                      const SizedBox(height: 30),

                      // ───────────────────────────────────
                      // Rating
                      // ───────────────────────────────────
                      _RatingCard(
                        userRating: _userRating,
                        submittingRating: _submittingRating,
                        onRatingSelected: _submitRating,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Rating Summary
// ═════════════════════════════════════════════════════════════

class _RatingSummary extends StatelessWidget {
  final double? rating;

  const _RatingSummary({required this.rating});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        ...List.generate(5, (index) {
          final filled = rating != null && index < rating!.round();

          return Icon(
            filled ? Icons.star : Icons.star_border,
            size: 18,
            color: Colors.amber,
          );
        }),
        const SizedBox(width: 8),
        Text(
          rating != null ? rating!.toStringAsFixed(1) : 'No ratings yet',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Section Title
// ═════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 21, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Info Card
// ═════════════════════════════════════════════════════════════

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Rating Card
// ═════════════════════════════════════════════════════════════

class _RatingCard extends StatelessWidget {
  final int? userRating;
  final bool submittingRating;
  final ValueChanged<int> onRatingSelected;

  const _RatingCard({
    required this.userRating,
    required this.submittingRating,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Rate this hotel',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Share your experience with other travelers.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final filled = userRating != null && starIndex <= userRating!;

              return IconButton(
                padding: const EdgeInsets.only(right: 6),
                constraints: const BoxConstraints(),
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: submittingRating
                    ? null
                    : () => onRatingSelected(starIndex),
              );
            }),
          ),

          if (submittingRating) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Submitting your rating...'),
              ],
            ),
          ],

          if (userRating != null && !submittingRating) ...[
            const SizedBox(height: 4),
            Text(
              'You rated this hotel $userRating out of 5.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Empty Gallery
// ═════════════════════════════════════════════════════════════

class _EmptyGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          'No photos available',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
