import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/shared/widgets/retryable_network_image.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/features/agency/agency_view/cubits/agencies/agencies_cubit.dart';
import 'package:tourify/features/agency/agency_view/cubits/agencies/agencies_state.dart';
import 'package:tourify/features/agency/agency_view/models/agency_model.dart';
import 'package:tourify/features/agency/agency_view/screens/agency_details_screen.dart';

class AgenciesListScreen extends StatelessWidget {
  const AgenciesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) =>
          AgenciesCubit(favoritesCubit: context.read<FavoritesCubit>())
            ..getAgencies(),
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
                  Icons.business_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Travel Offices',
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
        body: BlocBuilder<AgenciesCubit, AgenciesState>(
          builder: (context, state) {
            if (state is AgenciesLoading || state is AgenciesInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AgenciesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: colorScheme.error.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 34,
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
                        state.message,
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

            final agencies = (state as AgenciesLoaded).agencies;

            if (agencies.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business_outlined,
                          size: 38,
                          color: colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No travel offices found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'There are no travel offices available right now.',
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

            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 14,
                childAspectRatio: 0.70,
              ),
              itemCount: agencies.length,
              itemBuilder: (context, index) {
                return AgencyCard(agency: agencies[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class AgencyCard extends StatelessWidget {
  final AgencyModel agency;

  const AgencyCard({super.key, required this.agency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgencyDetailsScreen(agencyId: agency.id),
        ),
      ).then((_) => context.read<AgenciesCubit>().getAgencies()),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.055),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (agency.mainImageUrl != null)
                        RetryableNetworkImage(
                          url: agency.mainImageUrl!,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary.withOpacity(0.16),
                                colorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.business_rounded,
                            size: 42,
                            color: colorScheme.primary,
                          ),
                        ),

                      // Soft image gradient
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 75,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.50),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Favorite
                      Positioned(
                        top: 9,
                        right: 9,
                        child: BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, favState) {
                            final isFavorite = favState.isFavorite(
                              FavoriteType.agency,
                              agency.id,
                            );

                            return Material(
                              color: Colors.black.withOpacity(0.28),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => context
                                    .read<FavoritesCubit>()
                                    .toggle(FavoriteType.agency, agency.id),
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 19,
                                    color: isFavorite
                                        ? Colors.redAccent
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Rating badge
                      if (agency.averageRating != null)
                        Positioned(
                          left: 9,
                          bottom: 9,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.58),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  agency.averageRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 9),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  agency.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Row(
                  children: [
                    ...List.generate(5, (i) {
                      final filled =
                          agency.averageRating != null &&
                          i < agency.averageRating!.round();

                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 13,
                        color: Colors.amber.shade600,
                      );
                    }),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        agency.averageRating != null
                            ? agency.averageRating!.toStringAsFixed(1)
                            : 'No rating',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
