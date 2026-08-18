import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/create_package/cubits/places/places_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/places/places_state.dart';
import 'package:tourify/features/agency/create_package/models/place_model.dart';

class PlacePage extends StatelessWidget {
  final int countryId;
  final int cityId;

  const PlacePage({super.key, required this.countryId, required this.cityId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PlacesCubit()..getPlaces(countryId: countryId, cityId: cityId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          title: const Text(
            'Explore Places',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: BlocBuilder<PlacesCubit, PlacesState>(
          builder: (context, state) {
            if (state is PlacesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PlacesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.message, textAlign: TextAlign.center),
                ),
              );
            }

            if (state is PlacesLoaded) {
              if (state.places.isEmpty) {
                return const Center(
                  child: Text('لا يوجد أماكن سياحية بهذه المحافظة'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.places.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final place = state.places[index];

                  return _PlaceCard(
                    place: place,
                    onTap: () {
                      Navigator.pop<PlaceModel>(context, place);
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

class _PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;

  const _PlaceCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = place.images.isNotEmpty ? place.images.first : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _NetworkImage(url: image),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            place.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 3),

          Text(
            place.description.isEmpty ? 'Tourist place' : place.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
    if (url == null || url!.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      url!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _placeholder();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: const Color(0xFFEDEDF2),
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

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEDEDF2),
      alignment: Alignment.center,
      child: Icon(Icons.place_outlined, size: 38, color: Colors.grey.shade400),
    );
  }
}
