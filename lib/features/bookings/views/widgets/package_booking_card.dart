import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/const.dart';
import 'package:tourify/features/bookings/cubits/my_bookings_cubit.dart';
import '../../models/booking_group.dart';

class PackageBookingCard extends StatefulWidget {
  final PackageBookingGroup group;

  const PackageBookingCard({super.key, required this.group});

  @override
  State<PackageBookingCard> createState() => _PackageBookingCardState();
}

class _PackageBookingCardState extends State<PackageBookingCard> {
  bool _expanded = false;
  bool _cancelling = false;

  ({Color color, String label}) _statusInfo(PackageBookingGroup g) {
    if (g.isCompleted) return (color: kCompleted, label: 'Completed');
    switch (g.status) {
      case 'pending':
        return (color: kPending, label: 'Pending');
      case 'confirmed':
        return (color: kConfirmed, label: 'Confirmed');
      case 'rejected':
        return (color: kRejected, label: 'Rejected');
      default:
        return (color: Colors.grey, label: g.status);
    }
  }

  Future<void> _handleCancel() async {
    setState(() => _cancelling = true);
    try {
      await context.read<MyBookingsCubit>().cancelPackage(
        widget.group.packageId,
        widget.group.parent.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: kConfirmed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: kRejected,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final info = _statusInfo(g);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_travel_rounded,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Package #${g.packageId}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: 13,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              g.bookingDate,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.grey.shade100),
                  const SizedBox(height: 4),
                  _CountRow(
                    icon: Icons.hotel_rounded,
                    label: 'Hotel rooms',
                    count: g.hotelRoomsCount,
                  ),
                  _CountRow(
                    icon: Icons.flight_rounded,
                    label: 'Flights',
                    count: g.flightsCount,
                  ),
                  _CountRow(
                    icon: Icons.restaurant_rounded,
                    label: 'Restaurants',
                    count: g.restaurantsCount,
                  ),
                  if (g.status == 'pending') ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kRejected,
                          side: const BorderSide(color: kRejected),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _cancelling ? null : _handleCancel,
                        icon: _cancelling
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.close_rounded, size: 17),
                        label: Text(
                          _cancelling ? 'Cancelling...' : 'Cancel booking',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _CountRow({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
