import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/package_bookings_cubit.dart';
import '../cubit/package_bookings_state.dart';
import '../models/active_package_model.dart';
import '../models/package_booking_model.dart';

// ================= Design tokens =================
const _kPrimary = Color(0xFF0F766E); // teal
const _kPending = Color(0xFFD97706); // amber
const _kConfirmed = Color(0xFF16A34A); // green
const _kAvailable = Color(0xFF2563EB); // blue
const _kReject = Color(0xFFDC2626); // red
const _kBg = Color(0xFFF6F7FB);
const _kRadius = 18.0;

class PackageBookingsView extends StatelessWidget {
  final ActivePackageModel package;

  const PackageBookingsView({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackageBookingsCubit(package)..loadBookings(),
      child: _PackageBookingsScaffold(initialPackage: package),
    );
  }
}

class _PackageBookingsScaffold extends StatelessWidget {
  final ActivePackageModel initialPackage;

  const _PackageBookingsScaffold({required this.initialPackage});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(
          context,
          context.read<PackageBookingsCubit>().currentPackage,
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            initialPackage.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(
              context,
              context.read<PackageBookingsCubit>().currentPackage,
            ),
          ),
        ),
        body: BlocConsumer<PackageBookingsCubit, PackageBookingsState>(
          listener: (context, state) {
            if (state is PackageBookingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: _kReject,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PackageBookingsLoading ||
                state is PackageBookingsInitial) {
              return const Center(
                child: CircularProgressIndicator(color: _kPrimary),
              );
            }

            final package = _packageOf(state) ?? initialPackage;
            final bookings = _bookingsOf(state);
            final loadingBookingId = state is PackageBookingActionLoading
                ? state.bookingId
                : null;

            return Column(
              children: [
                _StatsBar(package: package),
                Expanded(
                  child: bookings == null
                      ? Center(
                          child: Text(
                            state is PackageBookingsError
                                ? state.message
                                : 'Something went wrong',
                          ),
                        )
                      : _BookingsList(
                          bookings: bookings,
                          loadingBookingId: loadingBookingId,
                          onApprove: (id) =>
                              context.read<PackageBookingsCubit>().approve(id),
                          onReject: (id) =>
                              context.read<PackageBookingsCubit>().reject(id),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ActivePackageModel? _packageOf(PackageBookingsState state) {
    if (state is PackageBookingsLoaded) return state.package;
    if (state is PackageBookingActionLoading) return state.package;
    return null;
  }

  List<PackageBookingModel>? _bookingsOf(PackageBookingsState state) {
    if (state is PackageBookingsLoaded) return state.bookings;
    if (state is PackageBookingActionLoading) return state.bookings;
    return null;
  }
}

// ================= Stats bar =================

class _StatsBar extends StatelessWidget {
  final ActivePackageModel package;

  const _StatsBar({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.event_seat_rounded,
            label: 'Total',
            value: package.quantity,
            color: Colors.blueGrey,
          ),
          _divider(),
          _StatItem(
            icon: Icons.hourglass_top_rounded,
            label: 'Pending',
            value: package.pendingCount,
            color: _kPending,
          ),
          _divider(),
          _StatItem(
            icon: Icons.verified_rounded,
            label: 'Confirmed',
            value: package.confirmedCount,
            color: _kConfirmed,
          ),
          _divider(),
          _StatItem(
            icon: Icons.event_available_rounded,
            label: 'Available',
            value: package.availableCount,
            color: _kAvailable,
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: Colors.grey.shade200);
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$value',
              key: ValueKey(value),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= Animated bookings list =================

class _BookingsList extends StatefulWidget {
  final List<PackageBookingModel> bookings;
  final int? loadingBookingId;
  final ValueChanged<int> onApprove;
  final ValueChanged<int> onReject;

  const _BookingsList({
    required this.bookings,
    required this.loadingBookingId,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<_BookingsList> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<PackageBookingModel> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = List.of(widget.bookings);
  }

  @override
  void didUpdateWidget(covariant _BookingsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldIds = _bookings.map((b) => b.id).toSet();
    final newIds = widget.bookings.map((b) => b.id).toSet();
    final removedIds = oldIds.difference(newIds);

    if (removedIds.isEmpty) {
      // fresh load (e.g. pull to refresh) — just sync silently
      if (widget.bookings.length != _bookings.length) {
        setState(() => _bookings = List.of(widget.bookings));
      }
      return;
    }

    for (final id in removedIds) {
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index == -1) continue;
      final removed = _bookings.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) =>
            _AnimatedCard(booking: removed, animation: animation, child: null),
        duration: const Duration(milliseconds: 320),
      );
    }

    Future.delayed(const Duration(milliseconds: 330), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bookings.isEmpty) {
      return const _EmptyState();
    }

    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      initialItemCount: _bookings.length,
      itemBuilder: (context, index, animation) {
        final booking = _bookings[index];
        return _AnimatedCard(
          booking: booking,
          animation: animation,
          child: _BookingCard(
            booking: booking,
            isLoading: widget.loadingBookingId == booking.id,
            onApprove: () => widget.onApprove(booking.id),
            onReject: () => widget.onReject(booking.id),
          ),
        );
      },
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  final PackageBookingModel booking;
  final Animation<double> animation;
  final Widget? child;

  const _AnimatedCard({
    required this.booking,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return SizeTransition(
      sizeFactor: curved,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child:
              child ??
              _BookingCard(
                booking: booking,
                isLoading: false,
                onApprove: () {},
                onReject: () {},
              ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, size: 40, color: _kPrimary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No pending booking requests',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= Booking card =================

class _BookingCard extends StatelessWidget {
  final PackageBookingModel booking;
  final bool isLoading;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _BookingCard({
    required this.booking,
    required this.isLoading,
    required this.onApprove,
    required this.onReject,
  });

  Color _avatarColor(String seed) {
    const palette = [
      Color(0xFF0F766E),
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
      Color(0xFF2563EB),
      Color(0xFFD97706),
      Color(0xFF16A34A),
    ];
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(
      booking.customerName.isEmpty ? '?' : booking.customerName,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withOpacity(0.15),
                  child: Text(
                    _initials(booking.customerName),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.customerName,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.call_rounded,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.customerPhone,
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
                    color: _kPending.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kPending,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Booking date: ${booking.bookingDate}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${booking.id}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      height: 42,
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      key: const ValueKey('actions'),
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kReject,
                              side: const BorderSide(
                                color: _kReject,
                                width: 1.4,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: onReject,
                            icon: const Icon(Icons.close_rounded, size: 17),
                            label: const Text(
                              'Reject',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kConfirmed,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: onApprove,
                            icon: const Icon(Icons.check_rounded, size: 17),
                            label: const Text(
                              'Approve',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
