import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/hotels/cubits/hotel_booking/hotel_booking_cubit.dart';
import 'package:tourify/features/hotels/cubits/hotel_booking/hotel_booking_state.dart';
import 'package:tourify/features/hotels/models/hotel_model.dart';
import 'package:tourify/shared/cubits/wallet/wallet_cubit.dart';

class RoomBookingSection extends StatefulWidget {
  final Map<String, List<HotelRoom>> roomsByType;
  const RoomBookingSection({super.key, required this.roomsByType});

  @override
  State<RoomBookingSection> createState() => _RoomBookingSectionState();
}

class _RoomBookingSectionState extends State<RoomBookingSection> {
  String? _selectedType;
  DateTimeRange? _selectedRange;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _selectedRange,
    );
    if (range != null) {
      setState(() => _selectedRange = range);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.roomsByType.isEmpty) return const SizedBox.shrink();

    final types = widget.roomsByType.keys.toList()..sort();
    final selectedRooms = _selectedType != null
        ? widget.roomsByType[_selectedType!]
        : null;
    final nights = _selectedRange != null
        ? _selectedRange!.end.difference(_selectedRange!.start).inDays
        : 0;
    final totalPrice = (selectedRooms != null && nights > 0)
        ? selectedRooms.first.price * nights
        : null;

    return BlocProvider(
      create: (_) => HotelBookingCubit(),
      child: BlocConsumer<HotelBookingCubit, HotelBookingState>(
        listener: (context, state) {
          if (state is HotelBookingSuccess) {
            context.read<WalletCubit>().refresh();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking confirmed! Status: pending'),
              ),
            );
            setState(() {
              _selectedType = null;
              _selectedRange = null;
            });
            context.read<HotelBookingCubit>().reset();
          } else if (state is HotelBookingFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isBooking = state is HotelBookingInProgress;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book a Room',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Room types
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: types.map((type) {
                  final room = widget.roomsByType[type]!.first;
                  final isSelected = _selectedType == type;

                  return ChoiceChip(
                    label: Text(
                      '$type  •  \$${room.price.toStringAsFixed(0)}/night  •  Sleeps ${room.capacity}',
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedType = type);
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    labelStyle: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),

              if (_selectedType != null) ...[
                const SizedBox(height: 16),

                // Booking details card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Booking Dates',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickDateRange,
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _selectedRange == null
                                ? 'Select booking dates'
                                : '${_selectedRange!.start.toString().split(' ')[0]}'
                                      ' → '
                                      '${_selectedRange!.end.toString().split(' ')[0]}',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      if (totalPrice != null) ...[
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$nights ${nights == 1 ? 'night' : 'nights'}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Total price',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${totalPrice.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Confirm booking button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (isBooking ||
                                  _selectedRange == null ||
                                  selectedRooms == null)
                              ? null
                              : () => context.read<HotelBookingCubit>().book(
                                  roomsOfType: selectedRooms,
                                  startDate: _selectedRange!.start,
                                  endDate: _selectedRange!.end,
                                ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isBooking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Confirm Booking',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
