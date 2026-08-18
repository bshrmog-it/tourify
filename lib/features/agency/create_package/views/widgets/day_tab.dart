import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/models/hotel_model.dart';
import 'package:tourify/features/agency/create_package/models/place_model.dart';
import 'package:tourify/features/agency/create_package/models/resturent_model.dart';

import '../pages/hotel_page.dart';
import '../pages/place_page.dart';
import '../pages/restaurant_page.dart';
import 'picker_bottom_sheet.dart';

class DayTab extends StatelessWidget {
  final int dayIndex;

  const DayTab({super.key, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PackageCreationCubit>();
    final state = context.watch<PackageCreationCubit>().state;

    // ================================================================
    // SAFETY
    // ================================================================

    if (dayIndex < 0 || dayIndex >= state.days.length) {
      return const Center(child: Text('Day not found'));
    }

    final day = state.days[dayIndex];
    final country = state.country;

    if (country == null) {
      return const Center(child: Text('اختر الدولة أولاً'));
    }

    final bool isFirstDay = dayIndex == 0;
    final bool isLastDay = dayIndex == state.days.length - 1;

    final bool showFlight = state.withFlight && (isFirstDay || isLastDay);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // DAY HEADER
          // ============================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.indigo),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${day.dayNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        day.date,
                        style: TextStyle(
                          color: Colors.grey.shade600,
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

          // ============================================================
          // CITY
          // ============================================================
          const _SectionTitle(
            title: 'Destination',
            icon: Icons.location_city_outlined,
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<int>(
            initialValue: day.cityId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'المحافظة / المدينة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: country.cities.map((city) {
              return DropdownMenuItem<int>(
                value: city.id,
                child: Text(city.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (id) {
              if (id != null) {
                cubit.setDayCity(dayIndex, id);
              }
            },
          ),

          const SizedBox(height: 24),

          // ============================================================
          // HOTEL
          // ============================================================
          const _SectionTitle(title: 'Hotel', icon: Icons.hotel_outlined),

          const SizedBox(height: 10),

          _PickCard(
            icon: Icons.hotel_outlined,
            title: day.hotel?.name ?? 'Add hotel',
            subtitle: day.hotel != null && day.roomType != null
                ? 'Room ${day.roomType}'
                : 'Choose a hotel for this day',
            imageUrl: day.hotel?.image,
            selected: day.hotel != null,
            onTap: () async {
              if (day.cityId == 0) {
                _showMessage(context, 'اختر المحافظة أولاً');
                return;
              }

              final hotel = await Navigator.push<HotelModel>(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return HotelPage(countryId: country.id, cityId: day.cityId);
                  },
                ),
              );

              if (hotel != null) {
                final firstDayRoomType = cubit.state.days.isNotEmpty
                    ? cubit.state.days.first.roomType
                    : null;

                final roomType = await _showRoomTypePicker(
                  context,
                  hotel,
                  lockedRoomType: dayIndex > 0 ? firstDayRoomType : null,
                );

                if (roomType != null) {
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
                }
              }
            },
          ),

          const SizedBox(height: 20),

          // ============================================================
          // TOURIST PLACE
          // ============================================================
          const _SectionTitle(
            title: 'Tourist Place',
            icon: Icons.place_outlined,
          ),

          const SizedBox(height: 10),

          _PickCard(
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
                _showMessage(context, 'اختر المحافظة أولاً');
                return;
              }

              final place = await Navigator.push<PlaceModel>(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return PlacePage(countryId: country.id, cityId: day.cityId);
                  },
                ),
              );

              if (place != null) {
                cubit.setDayPlace(dayIndex, place);
              }
            },
          ),

          const SizedBox(height: 20),

          // ============================================================
          // RESTAURANT
          // ============================================================
          const _SectionTitle(
            title: 'Restaurant',
            icon: Icons.restaurant_outlined,
          ),

          const SizedBox(height: 10),

          _PickCard(
            icon: Icons.restaurant_outlined,
            title: day.restaurant?.name ?? 'Add restaurant',
            subtitle: day.restaurant != null
                ? 'Restaurant'
                : 'Choose a restaurant',
            imageUrl: day.restaurant?.image,
            selected: day.restaurant != null,
            onTap: () async {
              if (day.cityId == 0) {
                _showMessage(context, 'اختر المحافظة أولاً');
                return;
              }

              final restaurant = await Navigator.push<RestaurantModel>(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return RestaurantPage(
                      countryId: country.id,
                      cityId: day.cityId,
                    );
                  },
                ),
              );

              if (restaurant != null) {
                cubit.setDayRestaurant(dayIndex, restaurant);
              }
            },
          ),

          // ============================================================
          // FLIGHT
          // ============================================================
          if (showFlight) ...[
            const SizedBox(height: 24),

            _SectionTitle(
              title: isFirstDay ? 'Departure Flight' : 'Return Flight',
              icon: Icons.flight_outlined,
            ),

            const SizedBox(height: 10),

            _FlightCard(
              flight: day.flight,
              isOutbound: isFirstDay,
              onTap: () {
                if (day.cityId == 0) {
                  _showMessage(
                    context,
                    'Please select a destination city first.',
                  );
                  return;
                }

                if (state.originCity == null) {
                  _showMessage(
                    context,
                    'Please select the departure city first.',
                  );
                  return;
                }

                _openFlightPicker(
                  context: context,
                  dayIndex: dayIndex,
                  countryId: country.id,
                  cityId: day.cityId,
                  date: day.date,
                  isOutbound: isFirstDay,
                  originCityId: state.originCity!.id,
                );
              },
              onRemove: day.flight == null
                  ? null
                  : () {
                      cubit.removeDayFlight(dayIndex);
                    },
            ),
          ],
        ],
      ),
    );
  }

  // ================================================================
  // FLIGHT PICKER
  // ================================================================

  void _openFlightPicker({
    required BuildContext context,
    required int dayIndex,
    required int countryId,
    required int cityId,
    required String date,
    required bool isOutbound,
    required int originCityId,
  }) {
    final cubit = context.read<PackageCreationCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: FlightPickerSheet(
            dayIndex: dayIndex,
            countryId: countryId,
            cityId: cityId,
            date: date,
            isOutbound: isOutbound,
            originCityId: originCityId,
          ),
        );
      },
    );
  }

  // ================================================================
  // MESSAGE
  // ================================================================

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

// ====================================================================
// SECTION TITLE
// ====================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ====================================================================
// PICK CARD
// ====================================================================

class _PickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const _PickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageUrl,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 82,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.indigo.shade200 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 62,
                  height: 62,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _placeholder();
                          },
                        )
                      : _placeholder(),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.indigo,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEDEDF2),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.grey.shade400, size: 28),
    );
  }
}

Future<String?> _showRoomTypePicker(
  BuildContext context,
  HotelModel hotel, {
  String? lockedRoomType,
}) {
  final availableRoomTypes = hotel.roomTypes;

  // Day 2+ must use the same room type as Day 1.
  if (lockedRoomType != null) {
    if (!availableRoomTypes.contains(lockedRoomType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'This hotel does not support Room $lockedRoomType. Please choose another hotel.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      });

      return Future.value(null);
    }

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Room Type',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  hotel.name,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                const SizedBox(height: 12),

                Text(
                  'Room type is locked to Room $lockedRoomType for all days.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),

                const SizedBox(height: 20),

                _RoomTypeOption(
                  type: lockedRoomType,
                  capacity: _roomCapacity(lockedRoomType),
                  onTap: () {
                    Navigator.pop(context, lockedRoomType);
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // Day 1: allow selecting the room type.
  final roomTypes = availableRoomTypes.isNotEmpty
      ? availableRoomTypes
      : ['A', 'B', 'C', 'D'];

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Room Type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                hotel.name,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 20),

              for (final type in roomTypes)
                _RoomTypeOption(
                  type: type,
                  capacity: _roomCapacity(type),
                  onTap: () {
                    Navigator.pop(context, type);
                  },
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}

int _roomCapacity(String type) {
  switch (type) {
    case 'A':
      return 4;
    case 'B':
      return 3;
    case 'C':
      return 2;
    case 'D':
      return 1;
    default:
      return 1;
  }
}

class _RoomTypeOption extends StatelessWidget {
  final String type;
  final int capacity;
  final VoidCallback onTap;

  const _RoomTypeOption({
    required this.type,
    required this.capacity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room $type',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$capacity ${capacity == 1 ? 'person' : 'people'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
// ====================================================================
// FLIGHT CARD
// ====================================================================

class _FlightCard extends StatelessWidget {
  final dynamic flight;
  final bool isOutbound;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _FlightCard({
    required this.flight,
    required this.isOutbound,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasFlight = flight != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFlight ? Colors.indigo.shade200 : Colors.grey.shade200,
            ),
          ),
          child: hasFlight
              ? Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flight, color: Colors.indigo),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOutbound ? 'Departure' : 'Return',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${flight.fromCity} → ${flight.toCity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

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

                    if (onRemove != null)
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flight_outlined,
                        color: Colors.indigo,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose flight',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text('Filtered by date and destination'),
                        ],
                      ),
                    ),

                    const Icon(Icons.chevron_right),
                  ],
                ),
        ),
      ),
    );
  }
}
