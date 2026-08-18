import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/shared/widgets/retryable_network_image.dart';
import 'package:tourify/features/restaurants/cubits/restaurant_details/restaurant_details_cubit.dart';
import 'package:tourify/features/restaurants/cubits/restaurant_details/restaurant_details_state.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final int restaurantId;

  const RestaurantDetailsScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RestaurantDetailsCubit(
            favoritesCubit: context.read<FavoritesCubit>(),
          )..getRestaurantDetails(restaurantId),
      child: _RestaurantDetailsView(restaurantId: restaurantId),
    );
  }
}

class _RestaurantDetailsView extends StatefulWidget {
  final int restaurantId;

  const _RestaurantDetailsView({required this.restaurantId});

  @override
  State<_RestaurantDetailsView> createState() => _RestaurantDetailsViewState();
}

class _RestaurantDetailsViewState extends State<_RestaurantDetailsView> {
  String? _selectedImageUrl;
  int? _userRating;
  bool _submittingRating = false;

  Future<void> _submitRating(int rating) async {
    setState(() {
      _userRating = rating;
      _submittingRating = true;
    });

    try {
      await context
          .read<RestaurantDetailsCubit>()
          .rateRestaurant(widget.restaurantId, rating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your rating!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "We couldn't submit your rating. Please try again.",
            ),
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
    return Scaffold(
      body: BlocBuilder<RestaurantDetailsCubit, RestaurantDetailsState>(
        builder: (context, state) {
          if (state is RestaurantDetailsLoading ||
              state is RestaurantDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RestaurantDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          }

          final restaurant = (state as RestaurantDetailsLoaded).restaurant;
          final heroImageUrl =
              _selectedImageUrl ?? restaurant.mainImageUrl;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Icon(
                                Icons.restaurant_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
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
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                            ),
                            if (restaurant.averageRating != null) ...[
                              const SizedBox(height: 8),
                              _RatingSummary(
                                rating: restaurant.averageRating!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: WalletBadge(),
                  ),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favState) {
                      final isFavorite = favState.isFavorite(
                        FavoriteType.restaurant,
                        restaurant.id,
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
                                    FavoriteType.restaurant,
                                    restaurant.id,
                                  );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        icon: Icons.info_outline,
                        title: 'About this restaurant',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        restaurant.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      if (restaurant.phone != null &&
                          restaurant.phone!.trim().isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionTitle(
                          icon: Icons.phone_outlined,
                          title: 'Contact',
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              restaurant.phone!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 30),
                      _SectionTitle(
                        icon: Icons.photo_library_outlined,
                        title: 'Photos',
                        trailing: restaurant.images.isNotEmpty
                            ? Text(
                                '${restaurant.images.length} photos',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      if (restaurant.images.isEmpty)
                        const _EmptyGallery()
                      else
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: restaurant.images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final imageUrl =
                                  restaurant.images[index].fullUrl;
                              final isSelected = heroImageUrl == imageUrl;

                              return GestureDetector(
                                onTap: () {
                                  setState(
                                    () => _selectedImageUrl = imageUrl,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 96,
                                  height: 96,
                                  padding:
                                      EdgeInsets.all(isSelected ? 3 : 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: isSelected
                                        ? Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _GlassIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(.30),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final double rating;

  const _RatingSummary({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < rating.round() ? Icons.star : Icons.star_border,
            size: 18,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 21,
          color: theme.colorScheme.primary,
        ),
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
                'Rate this restaurant',
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
              final filled =
                  userRating != null && starIndex <= userRating!;

              return IconButton(
                padding: const EdgeInsets.only(right: 6),
                constraints: const BoxConstraints(),
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed:
                    submittingRating ? null : () => onRatingSelected(starIndex),
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
              'You rated this restaurant $userRating out of 5.',
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

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

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
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
