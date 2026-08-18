import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

class HotelPickerSheet extends StatelessWidget {
  final int dayIndex;
  final int countryId;
  final int cityId;
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
      child: _PickerScaffold<HotelsCubit, HotelsState>(
        title: 'اختر الفندق',
        builder: (context, state) {
          if (state is HotelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HotelsError) {
            return Center(child: Text(state.message));
          }
          final hotels = state is HotelsLoaded ? state.hotels : const [];
          if (hotels.isEmpty) {
            return const Center(child: Text('لا يوجد فنادق بهالمحافظة'));
          }
          return ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (_, i) {
              final h = hotels[i];
              return ListTile(
                leading: h.image != null
                    ? Image.network(
                        h.image!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.hotel),
                title: Text(h.name),
                subtitle: h.roomTypes.isNotEmpty
                    ? Text('Rooms: ${h.roomTypes.join(', ')}')
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
  final int dayIndex;
  final int countryId;
  final int cityId;
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
      child: _PickerScaffold<PlacesCubit, PlacesState>(
        title: 'اختر المكان السياحي',
        builder: (context, state) {
          if (state is PlacesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PlacesError) {
            return Center(child: Text(state.message));
          }
          final places = state is PlacesLoaded ? state.places : const [];
          if (places.isEmpty) {
            return const Center(child: Text('لا يوجد أماكن سياحية بهالمحافظة'));
          }
          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (_, i) {
              final p = places[i];
              return ListTile(
                leading: p.images.isNotEmpty
                    ? Image.network(
                        p.images.first,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.place),
                title: Text(p.name),
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
  final int dayIndex;
  final int countryId;
  final int cityId;
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
      child: _PickerScaffold<RestaurantsCubit, RestaurantsState>(
        title: 'اختر المطعم',
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
            return const Center(child: Text('لا يوجد مطاعم بهالمحافظة'));
          }
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (_, i) {
              final r = restaurants[i];
              return ListTile(
                leading: r.image != null
                    ? Image.network(
                        r.image!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.restaurant),
                title: Text(r.name),
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
/// touch the chosen city - the user picks whichever leg fits that day
/// (outbound on day 1, return on the last day, etc.).
class FlightPickerSheet extends StatelessWidget {
  final int dayIndex;
  final int countryId;
  final int cityId;

  final int originCityId;

  final String date;

  /// true = first day / departure
  /// false = last day / return
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

  @override
  Widget build(BuildContext context) {
    final packageCubit = context.read<PackageCreationCubit>();

    return BlocProvider(
      create: (_) {
        return FlightsCubit()..getFlights(countryId: countryId, cityId: cityId);
      },
      child: _PickerScaffold<FlightsCubit, FlightsState>(
        title: isOutbound ? 'اختر رحلة الذهاب' : 'اختر رحلة العودة',
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

          // ============================================================
          // FILTER
          // ============================================================

          final flights = allFlights.where((item) {
            final flight = item.flight;
            final schedule = item.schedule;

            final flightDate = _normalizeDate(schedule.date);
            final selectedDate = _normalizeDate(date);

            if (flightDate != selectedDate) {
              return false;
            }

            if (schedule.seats <= 0) {
              return false;
            }

            if (isOutbound) {
              return flight.fromCityId == originCityId &&
                  flight.toCityId == cityId;
            }

            return flight.fromCityId == cityId &&
                flight.toCityId == originCityId;
          }).toList();
          // ============================================================
          // NO FLIGHTS
          // ============================================================

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
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      isOutbound
                          ? 'لا يوجد رحلات ذهاب متاحة'
                          : 'لا يوجد رحلات عودة متاحة',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'التاريخ: $date',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isOutbound
                          ? 'من مكان الانطلاق إلى المدينة السياحية'
                          : 'من المدينة السياحية إلى مكان الانطلاق',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          // ============================================================
          // FLIGHTS LIST
          // ============================================================

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: flights.length,
            separatorBuilder: (_, __) {
              return const SizedBox(height: 8);
            },
            itemBuilder: (_, index) {
              final item = flights[index];

              final airlineName = item.airlineName;
              final flight = item.flight;
              final schedule = item.schedule;

              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),

                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flight, color: Colors.indigo),
                  ),

                  title: Text(
                    '$airlineName: '
                    '${flight.fromCity} → '
                    '${flight.toCity}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${schedule.date}'),

                        const SizedBox(height: 4),

                        Text('Departure: ${schedule.departure}'),

                        Text('Arrival: ${schedule.arrival}'),

                        const SizedBox(height: 4),

                        Text(
                          '\$${flight.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  onTap: () {
                    packageCubit.setDayFlight(dayIndex, flight, schedule);
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

  String _normalizeDate(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    return value.length >= 10 ? value.substring(0, 10) : value;
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

class _PickerScaffold<C extends Cubit<S>, S> extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext, S) builder;
  const _PickerScaffold({required this.title, required this.builder});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(child: BlocBuilder<C, S>(builder: builder)),
          ],
        );
      },
    );
  }
}
