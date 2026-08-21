import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/shared/widgets/retryable_network_image.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/features/agency/agency_view/cubits/agency_details/agency_details_cubit.dart';
import 'package:tourify/features/agency/agency_view/cubits/agency_details/agency_details_state.dart';
import 'package:tourify/features/agency/agency_view/screens/view_package_screen.dart';

class AgencyDetailsScreen extends StatelessWidget {
  final int agencyId;

  const AgencyDetailsScreen({
    super.key,
    required this.agencyId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AgencyDetailsCubit(
        favoritesCubit: context.read<FavoritesCubit>(),
      )..getAgencyDetails(agencyId),
      child: _AgencyDetailsBody(agencyId: agencyId),
    );
  }
}

class _AgencyDetailsBody extends StatefulWidget {
  final int agencyId;

  const _AgencyDetailsBody({
    required this.agencyId,
  });

  @override
  State<_AgencyDetailsBody> createState() => _AgencyDetailsBodyState();
}

class _AgencyDetailsBodyState extends State<_AgencyDetailsBody> {
  int? _userRating;
  bool _submittingRating = false;

  Future<void> _submitRating(int rating) async {
    setState(() {
      _userRating = rating;
      _submittingRating = true;
    });

    try {
      await context
          .read<AgencyDetailsCubit>()
          .rateAgency(widget.agencyId, rating);
          await context.read<AgencyDetailsCubit>().getAgencyDetails(widget.agencyId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your rating!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not submit rating, please try again',
            ),
            behavior: SnackBarBehavior.floating,
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

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    dynamic pkg,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewPackageScreen(
                packageId: pkg.id,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.16),
                        colorScheme.primary.withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.card_travel_rounded,
                    color: colorScheme.primary,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pkg.numberOfDays} days',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '\$${pkg.price.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.42),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'How was your experience?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Your rating helps other travelers.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              final filled =
                  _userRating != null && starIndex <= _userRating!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedScale(
                  scale: filled ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 38,
                      minHeight: 38,
                    ),
                    icon: Icon(
                      filled
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber.shade600,
                      size: 32,
                    ),
                    onPressed: _submittingRating
                        ? null
                        : () => _submitRating(starIndex),
                  ),
                ),
              );
            }),
          ),
          if (_submittingRating) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<AgencyDetailsCubit, AgencyDetailsState>(
        builder: (context, state) {
          if (state is AgencyDetailsLoading ||
              state is AgencyDetailsInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AgencyDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 52,
                      color: colorScheme.error.withOpacity(0.75),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          final agency =
              (state as AgencyDetailsLoaded).agency;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                elevation: 0,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (agency.mainImageUrl != null)
                        RetryableNetworkImage(
                          url: agency.mainImageUrl!,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.business_rounded,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                        ),

                      // Dark gradient for readability
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.45, 1.0],
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.68),
                            ],
                          ),
                        ),
                      ),

                      // Bottom agency label
                      Positioned(
                        left: 18,
                        right: 70,
                        bottom: 20,
                        child: Text(
                          agency.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        final isFavorite = favState.isFavorite(
                          FavoriteType.agency,
                          agency.id,
                        );

                        return Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.32),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : Colors.white,
                              size: 21,
                            ),
                            onPressed: () => context
                                .read<FavoritesCubit>()
                                .toggle(
                                  FavoriteType.agency,
                                  agency.id,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        24,
                        18,
                        30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (agency.address != null ||
                              agency.landlinePhone != null)
                            Column(
                              children: [
                                if (agency.address != null)
                                  _buildInfoTile(
                                    context: context,
                                    icon: Icons.location_on_outlined,
                                    text: agency.address!,
                                  ),
                                if (agency.address != null &&
                                    agency.landlinePhone != null)
                                  const SizedBox(height: 9),
                                if (agency.landlinePhone != null)
                                  _buildInfoTile(
                                    context: context,
                                    icon: Icons.phone_outlined,
                                    text: agency.landlinePhone!,
                                  ),
                              ],
                            ),

                          if (agency.address != null ||
                              agency.landlinePhone != null)
                            const SizedBox(height: 28),

                          _buildSectionTitle(
                            context,
                            'About',
                            icon: Icons.info_outline_rounded,
                          ),

                          const SizedBox(height: 11),

                          Text(
                            agency.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.65,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 30),

                          _buildSectionTitle(
                            context,
                            'Packages by this office',
                            icon: Icons.card_travel_rounded,
                          ),

                          const SizedBox(height: 13),

                          if (agency.packages.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 28,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.35),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.luggage_outlined,
                                    size: 40,
                                    color: colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No packages yet',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...agency.packages.map(
                              (pkg) => _buildPackageCard(
                                context,
                                pkg,
                              ),
                            ),

                          const SizedBox(height: 18),

                          _buildSectionTitle(
                            context,
                            'Rate this office',
                            icon: Icons.star_outline_rounded,
                          ),

                          const SizedBox(height: 13),

                          _buildRatingCard(context),
                        ],
                      ),
                    ),
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