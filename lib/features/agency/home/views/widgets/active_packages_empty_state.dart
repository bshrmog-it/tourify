import 'package:flutter/material.dart';

import 'package_card.dart';

class ActivePackagesEmptyState extends StatelessWidget {
  const ActivePackagesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: colors.outline),
      ),

      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 50,
            color: colors.onSurfaceVariant,
          ),

          const SizedBox(height: 12),

          Text(
            'No active packages',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
