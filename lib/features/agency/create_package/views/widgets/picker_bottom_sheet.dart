import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/cubits/flights/flights_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/flights/flights_state.dart';
import 'package:tourify/features/agency/create_package/cubits/hotels/hotels_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/hotels/hotels_state.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/places/places_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/places/places_state.dart';
import 'package:tourify/features/agency/create_package/cubits/restaurants/restaurants_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/restaurants/restaurants_state.dart';
import 'package:tourify/features/agency/create_package/models/airline_model.dart';
import 'package:tourify/features/agency/create_package/models/flight_model.dart';
import 'picker_scaffold.dart';
import 'picker_list_tile.dart';

class HotelPickerSheet extends StatelessWidget {
  final int dayIndex, countryId, cityId;

  const HotelPickerSheet({
    super.key,
    required this.dayIndex,
    required this.countryId,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    final packageCubit = context.read<PackageCreationCubit>();

    return BlocProvider(
      create: (_) =>
          HotelsCubit()..getHotels(countryId: countryId, cityId: cityId),
      child: PickerScaffold<HotelsCubit, HotelsState>(
        title: 'Select a hotel',
        builder: (context, state) {
          if (state is HotelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotelsError) {
            return Center(child: Text(state.message));
          }

          final hotels = state is HotelsLoaded ? state.hotels : const [];

          if (hotels.isEmpty) {
            return const Center(child: Text('No hotels found in this city'));
          }

          return ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (_, i) {
              final h = hotels[i];

              return PickerListTile(
                imageUrl: h.image,
                placeholderIcon: Icons.hotel,
                title: h.name,
                subtitle: h.roomTypes.isNotEmpty
                    ? 'Rooms: ${h.roomTypes.join(', ')}'
                    : null,
                onTap: () {
                  packageCubit.setDayHotel(dayIndex, h);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PlacePickerSheet extends StatelessWidget {
  final int dayIndex, countryId, cityId;

  const PlacePickerSheet({
    super.key,
    required this.dayIndex,
    required this.countryId,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    final packageCubit = context.read<PackageCreationCubit>();

    return BlocProvider(
      create: (_) =>
          PlacesCubit()..getPlaces(countryId: countryId, cityId: cityId),
      child: PickerScaffold<PlacesCubit, PlacesState>(
        title: 'Select Tourist Place',
        builder: (context, state) {
          if (state is PlacesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlacesError) {
            return Center(child: Text(state.message));
          }

          final places = state is PlacesLoaded ? state.places : const [];

          if (places.isEmpty) {
            return const Center(
              child: Text('No tourist places available in this province.'),
            );
          }

          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (_, i) {
              final p = places[i];

              return PickerListTile(
                imageUrl: p.images.isNotEmpty ? p.images.first : null,
                placeholderIcon: Icons.place,
                title: p.name,
                onTap: () {
                  packageCubit.setDayPlace(dayIndex, p);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class RestaurantPickerSheet extends StatelessWidget {
  final int dayIndex, countryId, cityId;

  const RestaurantPickerSheet({
    super.key,
    required this.dayIndex,
    required this.countryId,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    final packageCubit = context.read<PackageCreationCubit>();

    return BlocProvider(
      create: (_) =>
          RestaurantsCubit()
            ..getRestaurants(countryId: countryId, cityId: cityId),
      child: PickerScaffold<RestaurantsCubit, RestaurantsState>(
        title: 'Select Restaurant',
        builder: (context, state) {
          if (state is RestaurantsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RestaurantsError) {
            return Center(child: Text(state.message));
          }

          final restaurants = state is RestaurantsLoaded
              ? state.restaurants
              : const [];

          if (restaurants.isEmpty) {
            return const Center(
              child: Text('No restaurants available in this province.'),
            );
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (_, i) {
              final r = restaurants[i];

              return PickerListTile(
                imageUrl: r.image,
                placeholderIcon: Icons.restaurant,
                title: r.name,
                onTap: () {
                  packageCubit.setDayRestaurant(dayIndex, r);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Flights are one-way, so this list mixes every airline's routes that
/// touch the chosen city - the user picks whichever leg fits that day.
class FlightPickerSheet extends StatelessWidget {
  final int dayIndex, countryId, cityId, originCityId;
  final String date;
  final bool isOutbound;

  const FlightPickerSheet({
    super.key,
    required this.dayIndex,
    required this.countryId,
    required this.cityId,
    required this.originCityId,
    required this.date,
    required this.isOutbound,
  });

  String _normalizeDate(String? value) => (value == null || value.isEmpty)
      ? ''
      : (value.length >= 10 ? value.substring(0, 10) : value);

  @override
  Widget build(BuildContext context) {
    final packageCubit = context.read<PackageCreationCubit>();

    return BlocProvider(
      create: (_) =>
          FlightsCubit()..getFlights(countryId: countryId, cityId: cityId),
      child: PickerScaffold<FlightsCubit, FlightsState>(
        title: isOutbound ? 'Select Departure Flight' : 'Select Return Flight',
        builder: (context, state) {
          if (state is FlightsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FlightsError) {
            return Center(child: Text(state.message));
          }

          final List<AirlineModel> airlines = state is FlightsLoaded
              ? state.airlines
              : const [];

          final allFlights = airlines
              .expand(
                (airline) => airline.flights.expand(
                  (flight) => flight.schedules.map(
                    (schedule) => FlightSelection(
                      airlineName: airline.name,
                      flight: flight,
                      schedule: schedule,
                    ),
                  ),
                ),
              )
              .toList();

          final flights = allFlights.where((item) {
            final flightDate = _normalizeDate(item.schedule.date);
            final selectedDate = _normalizeDate(date);

            if (flightDate != selectedDate) return false;
            if (item.schedule.seats <= 0) return false;

            if (isOutbound) {
              return item.flight.fromCityId == originCityId &&
                  item.flight.toCityId == cityId;
            }

            return item.flight.fromCityId == cityId &&
                item.flight.toCityId == originCityId;
          }).toList();

          if (flights.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flight_takeoff,
                      size: 52,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isOutbound
                          ? 'No outbound flights available'
                          : 'No return flights available',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: $date',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOutbound
                          ? 'From the departure city to the tourist destination'
                          : 'From the tourist destination to the departure city',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: flights.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = flights[index];

              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flight,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    '${item.airlineName}: ${item.flight.fromCity} → ${item.flight.toCity}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${item.schedule.date}'),
                        const SizedBox(height: 4),
                        Text('Departure: ${item.schedule.departure}'),
                        Text('Arrival: ${item.schedule.arrival}'),
                        const SizedBox(height: 4),
                        Text(
                          '\$${item.flight.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    packageCubit.setDayFlight(
                      dayIndex,
                      item.flight,
                      item.schedule,
                    );
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FlightSelection {
  final String airlineName;
  final FlightModel flight;
  final FlightScheduleModel schedule;

  FlightSelection({
    required this.airlineName,
    required this.flight,
    required this.schedule,
  });
}
