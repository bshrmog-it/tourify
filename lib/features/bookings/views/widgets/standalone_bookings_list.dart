import 'package:flutter/material.dart';
import 'package:tourify/core/const.dart';
import '../../models/booking_group.dart';
import '../../models/booking_model.dart';
import 'bookings_empty_state.dart';

class StandaloneBookingsList extends StatelessWidget {
  final List<StandaloneBooking> bookings;

  const StandaloneBookingsList({super.key, required this.bookings});

  IconData _iconFor(BookableType type) {
    switch (type) {
      case BookableType.hotelRoom:
        return Icons.hotel_rounded;
      case BookableType.flightSchedule:
        return Icons.flight_rounded;
      case BookableType.restaurant:
        return Icons.restaurant_rounded;
      case BookableType.place:
        return Icons.place_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _labelFor(BookableType type) {
    switch (type) {
      case BookableType.hotelRoom:
        return 'Hotel Room';
      case BookableType.flightSchedule:
        return 'Flight';
      case BookableType.restaurant:
        return 'Restaurant';
      case BookableType.place:
        return 'Place';
      default:
        return 'Booking';
    }
  }

  ({Color color, String label}) _statusInfo(String status) {
    switch (status) {
      case 'pending':
        return (color: kPending, label: 'Pending');
      case 'confirmed':
        return (color: kConfirmed, label: 'Confirmed');
      case 'rejected':
        return (color: kRejected, label: 'Rejected');
      default:
        return (color: Colors.grey, label: status);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const BookingsEmptyState(
        icon: Icons.event_busy_rounded,
        message: 'No individual bookings',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index].booking;
        final info = _statusInfo(b.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconFor(b.bookableType),
                  size: 19,
                  color: kPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_labelFor(b.bookableType)} #${b.bookableId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      b.bookingDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  info.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: info.color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
