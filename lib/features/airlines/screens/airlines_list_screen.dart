import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/airlines/cubits/airlines/airlines_cubit.dart';
import 'package:tourify/features/airlines/cubits/airlines/airlines_state.dart';
import 'package:tourify/features/airlines/models/airline_model.dart';
import 'package:tourify/features/airlines/screens/airline_flights_screen.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class AirlinesListScreen extends StatelessWidget {
  const AirlinesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AirlinesCubit(favoritesCubit: context.read<FavoritesCubit>())
            ..getAirlines(),
      child: const _AirlinesListView(),
    );
  }
}

class _AirlinesListView extends StatelessWidget {
  const _AirlinesListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Airlines'),
        centerTitle: false,
        elevation: 0,
        actions: const [
          Padding(padding: EdgeInsets.only(top: 8), child: WalletBadge()),
          SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<AirlinesCubit, AirlinesState>(
        builder: (context, state) {
          if (state is AirlinesLoading || state is AirlinesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AirlinesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          }

          final airlines = (state as AirlinesLoaded).airlines;

          if (airlines.isEmpty) {
            return const Center(child: Text('No airlines available.'));
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            itemCount: airlines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final airline = airlines[index];

              return _AirlineCard(airline: airline, primary: scheme.primary);
            },
          );
        },
      ),
    );
  }
}

class _AirlineCard extends StatelessWidget {
  final AirlineModel airline;
  final Color primary;

  const _AirlineCard({required this.airline, required this.primary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AirlineFlightsScreen(airline: airline),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.09),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  size: 30,
                  color: primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airline.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 17),
                        const SizedBox(width: 4),
                        Text(
                          airline.averageRating == null
                              ? 'No ratings'
                              : airline.averageRating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) {
                  final favorite = state.isFavorite(
                    FavoriteType.airline,
                    airline.id,
                  );

                  return IconButton(
                    tooltip: 'Favorite',
                    onPressed: () => context.read<FavoritesCubit>().toggle(
                      FavoriteType.airline,
                      airline.id,
                    ),
                    icon: Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: favorite ? primary : null,
                    ),
                  );
                },
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
