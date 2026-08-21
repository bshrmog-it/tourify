import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/create_package/cubits/restaurants/restaurants_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/restaurants/restaurants_state.dart';
import 'package:tourify/features/agency/create_package/models/resturent_model.dart';

class RestaurantPage extends StatelessWidget {
  final int countryId;
  final int cityId;

  const RestaurantPage({
    super.key,
    required this.countryId,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocProvider(
      create: (_) =>
          RestaurantsCubit()
            ..getRestaurants(countryId: countryId, cityId: cityId),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          foregroundColor: colors.onSurface,
          title: const Text(
            'Explore Restaurants',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: BlocBuilder<RestaurantsCubit, RestaurantsState>(
          builder: (context, state) {
            if (state is RestaurantsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RestaurantsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.message, textAlign: TextAlign.center),
                ),
              );
            }

            if (state is RestaurantsLoaded) {
              if (state.restaurants.isEmpty) {
                return const Center(
                  child: Text('No restaurants found in this city'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.restaurants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final restaurant = state.restaurants[index];

                  return _RestaurantCard(
                    restaurant: restaurant,
                    onTap: () {
                      Navigator.pop<RestaurantModel>(context, restaurant);
                    },
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const _RestaurantCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _NetworkImage(url: restaurant.image),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            restaurant.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 3),

          Text(
            restaurant.description.isEmpty
                ? 'Restaurant'
                : restaurant.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String? url;

  const _NetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (url == null || url!.isEmpty) {
      return _placeholder(context);
    }

    return Image.network(
      url!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _placeholder(context);
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: colors.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_outlined,
        size: 38,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
