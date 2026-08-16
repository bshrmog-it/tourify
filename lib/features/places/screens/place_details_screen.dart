import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/places/widgets/retryable_network_image.dart';
import 'package:tourify/features/places/cubits/place_details/place_details_cubit.dart';
import 'package:tourify/features/places/cubits/place_details/place_details_state.dart';
import 'package:tourify/features/places/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/features/places/cubits/favorites/favorites_state.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final int placeId;
  const PlaceDetailsScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlaceDetailsCubit()..getPlaceDetails(placeId),
      child: _PlaceDetailsView(placeId: placeId),
    );
  }
}

class _PlaceDetailsView extends StatefulWidget {
  final int placeId;
  const _PlaceDetailsView({required this.placeId});

  @override
  State<_PlaceDetailsView> createState() => _PlaceDetailsViewState();
}

class _PlaceDetailsViewState extends State<_PlaceDetailsView> {
  // الصورة المختارة حالياً لعرضها كبيرة فوق. null يعني "استخدم الصورة
  // الرئيسية الافتراضية" لحد ما المستخدم يضغط على واحدة من المصغّرات.
  String? _selectedImageUrl;

  // تقييم المستخدم الحالي (محلي، لعرض النجوم اللي اختارها قبل/أثناء الإرسال).
  int? _userRating;
  bool _submittingRating = false;

  Future<void> _submitRating(int rating) async {
    setState(() {
      _userRating = rating;
      _submittingRating = true;
    });
    try {
      await context.read<PlaceDetailsCubit>().ratePlace(widget.placeId, rating);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your rating!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("We couldn't send the rating; please try again."),
          ),
        );
        setState(() => _userRating = null);
      }
    } finally {
      if (mounted) setState(() => _submittingRating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaceDetailsCubit, PlaceDetailsState>(
        builder: (context, state) {
          if (state is PlaceDetailsLoading || state is PlaceDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PlaceDetailsError) {
            return Center(child: Text(state.message));
          }

          final loaded = state as PlaceDetailsLoaded;
          final place = loaded.place;
          final heroImageUrl = _selectedImageUrl ?? place.mainImageUrl;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: heroImageUrl != null
                      ? RetryableNetworkImage(
                          url: heroImageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey[300]),
                ),
                actions: [
                  // نفس الأيقونة يلي بشاشة القائمة، متصلة بنفس المصدر
                  // المشترك FavoritesCubit -> أي تغيير هون بينعكس فوراً هناك.
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favState) {
                      final isFavorite = favState.isFavorite(place.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () =>
                            context.read<FavoritesCubit>().toggle(place.id),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      if (place.averageRating != null)
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < place.averageRating!.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 18,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      const Divider(height: 32),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(place.description),
                      if (place.history != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'History',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(place.history!),
                      ],
                      const Divider(height: 32),
                      Text(
                        'Photos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: place.images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final imageUrl = place.images[index].fullUrl;
                            final isSelected = heroImageUrl == imageUrl;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImageUrl = imageUrl),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected
                                      ? Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: RetryableNetworkImage(
                                    url: imageUrl,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 32),
                      Text(
                        'How would you rate this place? :',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (i) {
                          final starIndex = i + 1;
                          final filled =
                              _userRating != null && starIndex <= _userRating!;
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              filled ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 28,
                            ),
                            onPressed: _submittingRating
                                ? null
                                : () => _submitRating(starIndex),
                          );
                        }),
                      ),
                      if (_submittingRating)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      // قسم Location موجود بالموكأب بس ما بنيته هون —
                      // الـ API الحالي ما بيرجع عنوان ولا إحداثيات للمكان.
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
