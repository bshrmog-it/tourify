import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/airlines/cubits/airline_rating/airline_rating_cubit.dart';
import 'package:tourify/features/airlines/cubits/airline_rating/airline_rating_state.dart';
import 'package:tourify/features/airlines/cubits/airline_flights/airline_flights_cubit.dart';
import 'package:tourify/features/airlines/cubits/airline_flights/airline_flights_state.dart';
import 'package:tourify/features/airlines/models/airline_model.dart';
import 'package:tourify/features/airlines/models/flight_model.dart';
import 'package:tourify/features/airlines/screens/flight_schedules_screen.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class AirlineFlightsScreen extends StatelessWidget {
  final AirlineModel airline;

  const AirlineFlightsScreen({super.key, required this.airline});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AirlineFlightsCubit()..getFlights(airline.id),
        ),
        BlocProvider(create: (_) => AirlineRatingCubit()),
      ],
      child: _AirlineFlightsView(airline: airline),
    );
  }
}

class _AirlineFlightsView extends StatelessWidget {
  final AirlineModel airline;

  const _AirlineFlightsView({required this.airline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 215,
              title: Text(
                airline.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [scheme.primary.withOpacity(.16), scheme.surface],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.flight_rounded, size: 72),
                  ),
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
                      FavoriteType.airline,
                      airline.id,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(right: 8, top: 8),
                      child: Material(
                        color: Colors.black.withOpacity(0.25),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: isFavorite
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            color: isFavorite ? Colors.redAccent : Colors.white,
                          ),
                          onPressed: () {
                            context.read<FavoritesCubit>().toggle(
                              FavoriteType.airline,
                              airline.id,
                            );
                          },
                        ),
                      ),
                    );

                    // return IconButton(
                    //   tooltip: 'Favorite',
                    //   onPressed: () => context.read<FavoritesCubit>().toggle(
                    //     FavoriteType.airline,
                    //     airline.id,
                    //   ),
                    //   icon: Icon(
                    //     favorite
                    //         ? Icons.favorite_rounded
                    //         : Icons.favorite_border_rounded,
                    //   ),
                    // );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            airline.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _RatingBadge(rating: airline.averageRating),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Credit: ${airline.credit}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Rate this airline',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    BlocConsumer<AirlineRatingCubit, AirlineRatingState>(
                      listener: (context, state) {
                        if (state is AirlineRatingSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rating saved.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (state is AirlineRatingError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final loading = state is AirlineRatingLoading;

                        return Row(
                          children: List.generate(5, (index) {
                            final value = index + 1;
                            return IconButton(
                              onPressed: loading
                                  ? null
                                  : () =>
                                        context.read<AirlineRatingCubit>().rate(
                                          airlineId: airline.id,
                                          rating: value,
                                        ),
                              icon: Icon(
                                Icons.star_rounded,
                                size: 31,
                                color:
                                    value <=
                                        (state is AirlineRatingSuccess
                                            ? state.rating
                                            : 0)
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Available flights',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<AirlineFlightsCubit, AirlineFlightsState>(
              builder: (context, state) {
                if (state is AirlineFlightsLoading ||
                    state is AirlineFlightsInitial) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is AirlineFlightsError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(state.message, textAlign: TextAlign.center),
                      ),
                    ),
                  );
                }

                final flights = (state as AirlineFlightsLoaded).flights;

                if (flights.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No flights available.')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                  sliver: SliverList.separated(
                    itemCount: flights.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final flight = flights[index];

                      return _FlightCard(
                        flight: flight,
                        airlineName: airline.name,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final FlightModel flight;
  final String airlineName;

  const _FlightCard({required this.flight, required this.airlineName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FlightSchedulesScreen(
                flight: flight,
                airlineName: airlineName,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.flight_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${flight.fromCity.name} → ${flight.toCity.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Flight #${flight.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${flight.price.toStringAsFixed(0)}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double? rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 17, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            rating == null ? '—' : rating!.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
