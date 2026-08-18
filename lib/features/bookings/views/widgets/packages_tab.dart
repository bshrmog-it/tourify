import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/const.dart';
import 'package:tourify/features/bookings/cubits/my_bookings_cubit.dart';
import '../../models/booking_filter.dart';
import '../../models/booking_group.dart';
import 'booking_filter_chip.dart';
import 'bookings_empty_state.dart';
import 'package_booking_card.dart';

class PackagesTab extends StatefulWidget {
  final List<PackageBookingGroup> groups;

  const PackagesTab({super.key, required this.groups});

  @override
  State<PackagesTab> createState() => _PackagesTabState();
}

class _PackagesTabState extends State<PackagesTab> {
  BookingFilter _filter = BookingFilter.all;

  int _statusPriority(PackageBookingGroup g) {
    if (g.status == 'pending') return 0;
    if (g.status == 'confirmed' && !g.isCompleted) return 1;
    if (g.isCompleted) return 2;
    if (g.status == 'rejected') return 3;
    return 4;
  }

  List<PackageBookingGroup> get _filtered {
    List<PackageBookingGroup> result;
    switch (_filter) {
      case BookingFilter.all:
        result = widget.groups;
        break;
      case BookingFilter.pending:
        result = widget.groups.where((g) => g.status == 'pending').toList();
        break;
      case BookingFilter.confirmed:
        result = widget.groups
            .where((g) => g.status == 'confirmed' && !g.isCompleted)
            .toList();
        break;
      case BookingFilter.completed:
        result = widget.groups.where((g) => g.isCompleted).toList();
        break;
      case BookingFilter.rejected:
        result = widget.groups.where((g) => g.status == 'rejected').toList();
        break;
    }
    final sorted = List.of(result);
    sorted.sort((a, b) => _statusPriority(a).compareTo(_statusPriority(b)));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isEmpty) {
      return const BookingsEmptyState(
        icon: Icons.card_travel_rounded,
        message: 'No package bookings yet',
      );
    }

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: () => context.read<MyBookingsCubit>().load(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  BookingFilterChip(
                    label: 'All',
                    value: BookingFilter.all,
                    current: _filter,
                    color: kPrimary,
                    onTap: (v) => setState(() => _filter = v),
                  ),
                  const SizedBox(width: 8),
                  BookingFilterChip(
                    label: 'Pending',
                    value: BookingFilter.pending,
                    current: _filter,
                    color: kPending,
                    onTap: (v) => setState(() => _filter = v),
                  ),
                  const SizedBox(width: 8),
                  BookingFilterChip(
                    label: 'Confirmed',
                    value: BookingFilter.confirmed,
                    current: _filter,
                    color: kCompleted,
                    onTap: (v) => setState(() => _filter = v),
                  ),
                  const SizedBox(width: 8),
                  BookingFilterChip(
                    label: 'Completed',
                    value: BookingFilter.completed,
                    current: _filter,
                    color: kCompleted,
                    onTap: (v) => setState(() => _filter = v),
                  ),
                  const SizedBox(width: 8),
                  BookingFilterChip(
                    label: 'Rejected',
                    value: BookingFilter.rejected,
                    current: _filter,
                    color: kRejected,
                    onTap: (v) => setState(() => _filter = v),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const BookingsEmptyState(
                    icon: Icons.filter_alt_off_rounded,
                    message: 'Nothing here for this filter',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) =>
                        PackageBookingCard(group: _filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
