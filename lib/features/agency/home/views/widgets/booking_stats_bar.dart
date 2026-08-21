import 'package:flutter/material.dart';

import '../../models/active_package_model.dart';
import 'package_card.dart';

class BookingStatsBar extends StatelessWidget {
  final ActivePackageModel package;

  const BookingStatsBar({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),

      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),

      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(kRadius),

        border: Border.all(color: colors.outline.withOpacity(0.5)),

        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.12),
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

          _divider(context),

          _StatItem(
            icon: Icons.hourglass_top_rounded,
            label: 'Pending',
            value: package.pendingCount,
            color: kPending,
          ),

          _divider(context),

          _StatItem(
            icon: Icons.verified_rounded,
            label: 'Confirmed',
            value: package.confirmedCount,
            color: kConfirmed,
          ),

          _divider(context),

          _StatItem(
            icon: Icons.event_available_rounded,
            label: 'Available',
            value: package.availableCount,
            color: kAvailable,
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 36,
      color: colors.outline.withOpacity(0.5),
    );
  }
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
    final colors = Theme.of(context).colorScheme;

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

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
