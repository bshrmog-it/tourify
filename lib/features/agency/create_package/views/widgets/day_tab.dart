import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/models/hotel_model.dart';
import 'package:tourify/features/agency/create_package/models/place_model.dart';
import 'package:tourify/features/agency/create_package/models/resturent_model.dart';
import 'package:tourify/features/agency/create_package/views/widgets/room_type_picker_sheet.dart';
import 'package:tourify/features/agency/create_package/views/widgets/section_title.dart';
import '../pages/hotel_page.dart';
import '../pages/place_page.dart';
import '../pages/restaurant_page.dart';
import 'day_pick_card.dart';
import 'day_flight_card.dart';
import 'picker_bottom_sheet.dart';

class DayTab extends StatelessWidget {
  final int dayIndex;

  const DayTab({super.key, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PackageCreationCubit>();
    final state = context.watch<PackageCreationCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    if (dayIndex < 0 || dayIndex >= state.days.length) {
      return Center(
        child: Text(
          'Day not found',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      );
    }

    final day = state.days[dayIndex];
    final country = state.country;

    if (country == null) {
      return Center(
        child: Text(
          'Select a country first',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      );
    }

    final isFirstDay = dayIndex == 0;
    final isLastDay = dayIndex == state.days.length - 1;
    final showFlight = state.withFlight && (isFirstDay || isLastDay);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${day.dayNumber}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.date,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const SectionTitle(
            title: 'Destination',
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<int>(
            initialValue: day.cityId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Province / City',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            items: country.cities
                .map(
                  (city) => DropdownMenuItem<int>(
                    value: city.id,
                    child: Text(
                      city.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              if (id != null) cubit.setDayCity(dayIndex, id);
            },
          ),
          const SizedBox(height: 24),

          const SectionTitle(title: 'Hotel', icon: Icons.hotel_outlined),
          const SizedBox(height: 10),

          DayPickCard(
            icon: Icons.hotel_outlined,
            title: day.hotel?.name ?? 'Add hotel',
            subtitle: day.hotel != null && day.roomType != null
                ? 'Room ${day.roomType}'
                : 'Choose a hotel for this day',
            imageUrl: day.hotel?.image,
            selected: day.hotel != null,
            onTap: () async {
              if (day.cityId == 0) {
                return _showMessage(context, 'Please select a province first.');
              }

              final hotel = await Navigator.push<HotelModel>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      HotelPage(countryId: country.id, cityId: day.cityId),
                ),
              );

              if (hotel == null) return;

              final firstDayRoomType = cubit.state.days.isNotEmpty
                  ? cubit.state.days.first.roomType
                  : null;

              final roomType = await showRoomTypePicker(
                context,
                hotel,
                lockedRoomType: dayIndex > 0 ? firstDayRoomType : null,
              );

              if (roomType == null) return;

              if (dayIndex > 0 &&
                  firstDayRoomType != null &&
                  !hotel.roomTypes.contains(firstDayRoomType)) {
                _showMessage(
                  context,
                  'This hotel does not support Room $firstDayRoomType. Please choose another hotel.',
                );
                return;
              }

              cubit.setDayHotel(dayIndex, hotel, roomType: roomType);
            },
          ),
          const SizedBox(height: 20),

          const SectionTitle(
            title: 'Tourist Place',
            icon: Icons.place_outlined,
          ),
          const SizedBox(height: 10),

          DayPickCard(
            icon: Icons.place_outlined,
            title: day.place?.name ?? 'Add place',
            subtitle: day.place != null
                ? 'Tourist place'
                : 'Choose a place to visit',
            imageUrl: day.place != null && day.place!.images.isNotEmpty
                ? day.place!.images.first
                : null,
            selected: day.place != null,
            onTap: () async {
              if (day.cityId == 0) {
                return _showMessage(context, 'Please select a province first.');
              }

              final place = await Navigator.push<PlaceModel>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PlacePage(countryId: country.id, cityId: day.cityId),
                ),
              );

              if (place != null) {
                cubit.setDayPlace(dayIndex, place);
              }
            },
          ),
          const SizedBox(height: 20),

          const SectionTitle(
            title: 'Restaurant',
            icon: Icons.restaurant_outlined,
          ),
          const SizedBox(height: 10),

          DayPickCard(
            icon: Icons.restaurant_outlined,
            title: day.restaurant?.name ?? 'Add restaurant',
            subtitle: day.restaurant != null
                ? 'Restaurant'
                : 'Choose a restaurant',
            imageUrl: day.restaurant?.image,
            selected: day.restaurant != null,
            onTap: () async {
              if (day.cityId == 0) {
                return _showMessage(context, 'Please select a province first.');
              }

              final restaurant = await Navigator.push<RestaurantModel>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RestaurantPage(countryId: country.id, cityId: day.cityId),
                ),
              );

              if (restaurant != null) {
                cubit.setDayRestaurant(dayIndex, restaurant);
              }
            },
          ),

          if (showFlight) ...[
            const SizedBox(height: 24),

            SectionTitle(
              title: isFirstDay ? 'Departure Flight' : 'Return Flight',
              icon: Icons.flight_outlined,
            ),
            const SizedBox(height: 10),

            DayFlightCard(
              flight: day.flight,
              isOutbound: isFirstDay,
              onTap: () {
                if (day.cityId == 0) {
                  return _showMessage(
                    context,
                    'Please select a destination city first.',
                  );
                }

                if (state.originCity == null) {
                  return _showMessage(
                    context,
                    'Please select the departure city first.',
                  );
                }

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: FlightPickerSheet(
                      dayIndex: dayIndex,
                      countryId: country.id,
                      cityId: day.cityId,
                      date: day.date,
                      isOutbound: isFirstDay,
                      originCityId: state.originCity!.id,
                    ),
                  ),
                );
              },
              onRemove: day.flight == null
                  ? null
                  : () => cubit.removeDayFlight(dayIndex),
            ),
          ],
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
