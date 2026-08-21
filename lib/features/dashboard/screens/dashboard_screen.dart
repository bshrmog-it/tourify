import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/theme/theme_controller.dart';
import 'package:tourify/features/dashboard/services/get_dashboard.dart';

import 'package:tourify/shared/widgets/wallet_badge.dart';
import 'package:tourify/shared/services/location_lookup_service.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';

import 'package:tourify/features/dashboard/cubits/dashboard/dashboard_cubit.dart';
import 'package:tourify/features/dashboard/cubits/dashboard/dashboard_state.dart';
import 'package:tourify/features/dashboard/services/search_dashboard.dart';
import 'package:tourify/features/dashboard/widgets/dashboard_widgets.dart';

import 'package:tourify/features/places/screens/places_list_screen.dart';
import 'package:tourify/features/places/screens/place_details_screen.dart';

import 'package:tourify/features/hotels/screens/hotels_list_screen.dart';
import 'package:tourify/features/hotels/screens/hotel_details_screen.dart';

import 'package:tourify/features/restaurants/screens/restaurants_list_screen.dart';
import 'package:tourify/features/restaurants/screens/restaurant_details_screen.dart';

import 'package:tourify/features/agency/agency_view/screens/agencies_list_screen.dart';
import 'package:tourify/features/agency/agency_view/screens/agency_details_screen.dart';

import 'package:tourify/features/packages/package_user/screens/packages_list_screen.dart';

import 'package:tourify/features/airlines/screens/airlines_list_screen.dart';
import 'package:tourify/features/airlines/screens/airline_flights_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardCubit(favoritesCubit: context.read<FavoritesCubit>())
            ..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final _searchController = TextEditingController();
  final _searchService = SearchDashboard();

  String _query = '';
  Timer? _debounce;

  DashboardData? _searchResults;
  bool _searching = false;

  List<String> _countries = [];
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();

    LocationLookupService.instance.getCountryNames().then((names) {
      if (mounted) {
        setState(() => _countries = names);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Refresh dashboard after returning from a details screen.
  ///
  /// This keeps ratings/favorites/counts up to date without
  /// requiring a full application restart.
  void _refresh() {
    if (!mounted) return;

    context.read<DashboardCubit>().load(
          country: _selectedCountry,
        );
  }

  /// Opens a details screen and refreshes the dashboard when
  /// the user comes back.
  Future<void> _pushAndRefresh(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (mounted) {
      _refresh();
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);

    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _searching = false;
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () async {
        if (!mounted) return;

        setState(() => _searching = true);

        try {
          final results = await _searchService.search(value.trim());

          if (mounted) {
            setState(() => _searchResults = results);
          }
        } catch (_) {
          if (mounted) {
            setState(() => _searchResults = null);
          }
        } finally {
          if (mounted) {
            setState(() => _searching = false);
          }
        }
      },
    );
  }

  Future<void> _pickCountry() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Choose a country',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),

            ListTile(
              leading: Icon(
                Icons.public_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text(
                'All countries',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: _selectedCountry == null
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () => Navigator.pop(context, null),
            ),

            for (final country in _countries)
              ListTile(
                leading: Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(country),
                trailing: _selectedCountry == country
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(context, country),
              ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    setState(() => _selectedCountry = selected);

    context.read<DashboardCubit>().load(
          country: selected,
        );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          key: const ValueKey('dashboard-search-field'),
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search places, hotels, restaurants...',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 13.5,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
            ),
            suffixIcon: _searching
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                : (_query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                color: colorScheme.primary.withOpacity(0.35),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searching && _searchResults == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final results = _searchResults;

    final items = <Widget>[
      ...?results?.places.map(
        (p) => ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.landscape_outlined),
          ),
          title: Text(p.name),
          subtitle: const Text('Tourist Place'),
          onTap: () => _pushAndRefresh(
            PlaceDetailsScreen(placeId: p.id),
          ),
        ),
      ),

      ...?results?.hotels.map(
        (h) => ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.hotel_outlined),
          ),
          title: Text(h.name),
          subtitle: const Text('Hotel'),
          onTap: () => _pushAndRefresh(
            HotelDetailsScreen(hotelId: h.id),
          ),
        ),
      ),

      ...?results?.restaurants.map(
        (r) => ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.restaurant_outlined),
          ),
          title: Text(r.name),
          subtitle: const Text('Restaurant'),
          onTap: () => _pushAndRefresh(
            RestaurantDetailsScreen(restaurantId: r.id),
          ),
        ),
      ),

      ...?results?.agencies.map(
        (a) => ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.business_outlined),
          ),
          title: Text(a.name),
          subtitle: const Text('Travel Office'),
          onTap: () => _pushAndRefresh(
            AgencyDetailsScreen(agencyId: a.id),
          ),
        ),
      ),

      ...?results?.airlines.map(
        (a) => ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.flight_outlined),
          ),
          title: Text(a.name),
          subtitle: const Text('Airline'),
          onTap: () => _pushAndRefresh(
            AirlineFlightsScreen(airline: a),
          ),
        ),
      ),
    ];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 52,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching for something else',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      children: items,
    );
  }

  Widget _buildCountryFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasCountry = _selectedCountry != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: colorScheme.primary.withOpacity(
            hasCountry ? 0.14 : 0.08,
          ),
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: _pickCountry,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 9,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.public_rounded,
                    size: 17,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _selectedCountry ?? 'All countries',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackagesCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Material(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PackagesListScreen(),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.card_travel_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explore Packages',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover complete multi-day trips',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.explore_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Tourify',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: ThemeController.mode.value == ThemeMode.dark
                ? 'Light mode'
                : 'Dark mode',
            onPressed: () {
              ThemeController.toggle();
            },
            icon: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.mode,
              builder: (context, mode, _) {
                return Icon(
                  mode == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                );
              },
            ),
          ),
          const WalletBadge(),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          _buildSearchBar(),

          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                // Search has priority over dashboard browsing/loading.
                if (_query.trim().isNotEmpty) {
                  return _buildSearchResults(context);
                }

                if (state is DashboardLoading ||
                    state is DashboardInitial) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is DashboardError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final data = (state as DashboardLoaded).data;

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<DashboardCubit>().load(
                          country: _selectedCountry,
                        );
                  },
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(top: 2),
                    children: [
                      _buildCountryFilter(),

                      HorizontalSection(
                        title: 'Tourist Places',
                        icon: Icons.landscape_outlined,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlacesListScreen(),
                          ),
                        ),
                        children: data.places
                            .map(
                              (p) => DashboardPreviewCard(
                                imageUrl: p.mainImageUrl,
                                title: p.name,
                                rating: p.averageRating,
                                onTap: () => _pushAndRefresh(
                                  PlaceDetailsScreen(placeId: p.id),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      HorizontalSection(
                        title: 'Hotels',
                        icon: Icons.hotel_outlined,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HotelsListScreen(),
                          ),
                        ),
                        children: data.hotels
                            .map(
                              (h) => DashboardPreviewCard(
                                imageUrl: h.mainImageUrl,
                                title: h.name,
                                rating: h.averageRating,
                                onTap: () => _pushAndRefresh(
                                  HotelDetailsScreen(hotelId: h.id),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      HorizontalSection(
                        title: 'Restaurants',
                        icon: Icons.restaurant_outlined,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RestaurantsListScreen(),
                          ),
                        ),
                        children: data.restaurants
                            .map(
                              (r) => DashboardPreviewCard(
                                imageUrl: r.mainImageUrl,
                                title: r.name,
                                rating: r.averageRating,
                                onTap: () => _pushAndRefresh(
                                  RestaurantDetailsScreen(
                                    restaurantId: r.id,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      HorizontalSection(
                        title: 'Airlines',
                        icon: Icons.flight_outlined,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AirlinesListScreen(),
                          ),
                        ),
                        children: data.airlines
                            .map(
                              (a) => DashboardPreviewCard(
                                imageUrl: null,
                                title: a.name,
                                rating: a.averageRating,
                                fallbackIcon:
                                    Icons.flight_takeoff_rounded,
                                onTap: () => _pushAndRefresh(
                                  AirlineFlightsScreen(airline: a),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      HorizontalSection(
                        title: 'Travel Offices',
                        icon: Icons.business_outlined,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AgenciesListScreen(),
                          ),
                        ),
                        children: data.agencies
                            .map(
                              (agency) => DashboardPreviewCard(
                                imageUrl: agency.mainImageUrl,
                                title: agency.name,
                                rating: agency.averageRating,
                                onTap: () => _pushAndRefresh(
                                  AgencyDetailsScreen(
                                    agencyId: agency.id,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      _buildPackagesCard(context),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}