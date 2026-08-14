import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/places/widgets/retryable_network_image.dart';
import 'package:tourify/features/places/cubits/places/places_cubit.dart';
import 'package:tourify/features/places/cubits/places/places_state.dart';
import 'package:tourify/features/places/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/features/places/cubits/favorites/favorites_state.dart';
import 'package:tourify/features/places/models/place_model.dart';
import 'package:tourify/features/places/services/location_lookup_service.dart';
import 'package:tourify/features/places/screens/place_details_screen.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlacesCubit()..getPlaces(),
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
  // بتتحمل مرة وحدة بس (الـ service نفسه بعمل cache داخلي)، وبتنعاد
  // بنائها لباقي شاشات المشروع من غير ما تعيد الطلب لـ /api/country.
  Map<int, String> _cityLabels = {};

  @override
  void initState() {
    super.initState();
    LocationLookupService.instance.getCityLabels().then((labels) {
      if (mounted) setState(() => _cityLabels = labels);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tourist places')),
      body: BlocBuilder<PlacesCubit, PlacesState>(
        builder: (context, state) {
          if (state is PlacesLoading || state is PlacesInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PlacesError) {
            return Center(child: Text(state.message));
          }
          final places = (state as PlacesLoaded).places;
          if (places.isEmpty) {
            return const Center(child: Text('No places found'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: places.length,
            itemBuilder: (context, index) => PlaceCard(
              place: places[index],
              cityLabel: _cityLabels[places[index].cityId],
            ),
          );
        },
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final String? cityLabel;
  const PlaceCard({super.key, required this.place, this.cityLabel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaceDetailsScreen(placeId: place.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox.expand(
                    child: place.mainImageUrl != null
                        ? RetryableNetworkImage(
                            url: place.mainImageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey[300]),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  // BlocBuilder محصور بس عالأيقونة، فما يعيد بناء الصورة
                  // أو الكارد كامل كل ما تتغير حالة المفضلة.
                  child: BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favState) {
                      final isFavorite = favState.isFavorite(place.id);
                      return GestureDetector(
                        onTap: () =>
                            context.read<FavoritesCubit>().toggle(place.id),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFavorite ? Colors.red : Colors.black54,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            place.name,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              ...List.generate(5, (i) {
                final filled =
                    place.averageRating != null &&
                    i < place.averageRating!.round();
                return Icon(
                  filled ? Icons.star : Icons.star_border,
                  size: 12,
                  color: Colors.amber,
                );
              }),
              const SizedBox(width: 4),
              Text(
                place.averageRating != null
                    ? place.averageRating!.toStringAsFixed(1)
                    : 'No ratings yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Text(
            cityLabel ?? '...',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
