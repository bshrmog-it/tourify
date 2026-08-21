import 'package:flutter/material.dart';

import '../../models/package_booking_model.dart';
import 'package_card.dart';

const kReject = Color(0xFFDC2626);
const kPendingBadge = Color(0xFFD97706);
const kConfirmedBtn = Color(0xFF16A34A);

class BookingRequestCard extends StatelessWidget {
  final PackageBookingModel booking;
  final bool isLoading;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const BookingRequestCard({
    super.key,
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

    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final color = _avatarColor(
      booking.customerName.isEmpty ? '?' : booking.customerName,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: colors.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.12),
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
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          Icon(
                            Icons.call_rounded,
                            size: 13,
                            color: colors.onSurfaceVariant,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            booking.customerPhone,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: colors.onSurfaceVariant,
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
                    color: kPendingBadge.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kPendingBadge,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),

              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: colors.onSurfaceVariant,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Booking date: ${booking.bookingDate}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '#${booking.id}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant.withOpacity(0.65),
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
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      height: 42,

                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: colors.primary,
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
                              foregroundColor: kReject,

                              side: const BorderSide(
                                color: kReject,
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
                              backgroundColor: kConfirmedBtn,
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
