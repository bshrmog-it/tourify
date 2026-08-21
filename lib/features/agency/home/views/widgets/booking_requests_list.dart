import 'package:flutter/material.dart';

import '../../models/package_booking_model.dart';
import 'booking_request_card.dart';
import 'package_card.dart';

class BookingRequestsList extends StatefulWidget {
  final List<PackageBookingModel> bookings;
  final int? loadingBookingId;
  final ValueChanged<int> onApprove;
  final ValueChanged<int> onReject;

  const BookingRequestsList({
    super.key,
    required this.bookings,
    required this.loadingBookingId,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<BookingRequestsList> createState() => _BookingRequestsListState();
}

class _BookingRequestsListState extends State<BookingRequestsList> {
  final _listKey = GlobalKey<AnimatedListState>();

  late List<PackageBookingModel> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = List.of(widget.bookings);
  }

  @override
  void didUpdateWidget(covariant BookingRequestsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldIds = _bookings.map((b) => b.id).toSet();

    final newIds = widget.bookings.map((b) => b.id).toSet();

    final removedIds = oldIds.difference(newIds);

    if (removedIds.isEmpty) {
      if (widget.bookings.length != _bookings.length) {
        setState(() {
          _bookings = List.of(widget.bookings);
        });
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
      if (mounted) {
        setState(() {});
      }
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

          child: BookingRequestCard(
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
              BookingRequestCard(
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
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),

            child: Icon(Icons.inbox_rounded, size: 40, color: colors.primary),
          ),

          const SizedBox(height: 16),

          Text(
            'No pending booking requests',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
