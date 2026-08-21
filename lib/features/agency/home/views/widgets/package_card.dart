import 'package:flutter/material.dart';

import 'package:tourify/features/agency/home/models/active_package_model.dart';

const kPrimary = Color(0xFF0F766E);
const kPending = Color(0xFFD97706);
const kConfirmed = Color(0xFF16A34A);
const kAvailable = Color(0xFF2563EB);
const kRadius = 18.0;

class PackageCard extends StatelessWidget {
  final ActivePackageModel package;
  final VoidCallback onTap;

  const PackageCard({super.key, required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(kRadius),

        border: Border.all(color: colors.outline.withOpacity(0.5)),

        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(kRadius),

        child: InkWell(
          borderRadius: BorderRadius.circular(kRadius),
          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            package.name,

                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),

                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              if (package.countryName != null) ...[
                                Icon(
                                  Icons.place_rounded,
                                  size: 14,
                                  color: colors.onSurfaceVariant,
                                ),

                                const SizedBox(width: 3),

                                Text(
                                  package.countryName!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(width: 10),
                              ],

                              Icon(
                                Icons.nights_stay_rounded,
                                size: 14,
                                color: colors.onSurfaceVariant,
                              ),

                              const SizedBox(width: 3),

                              Text(
                                '${package.numberOfDays} days',
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
                        horizontal: 12,
                        vertical: 7,
                      ),

                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        '\$${package.price.toStringAsFixed(0)}',

                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _StatChip(
                      label: 'Total',
                      value: package.quantity,
                      color: Colors.blueGrey,
                    ),

                    const SizedBox(width: 8),

                    _StatChip(
                      label: 'Pending',
                      value: package.pendingCount,
                      color: kPending,
                    ),

                    const SizedBox(width: 8),

                    _StatChip(
                      label: 'Confirmed',
                      value: package.confirmedCount,
                      color: kConfirmed,
                    ),

                    const SizedBox(width: 8),

                    _StatChip(
                      label: 'Available',
                      value: package.availableCount,
                      color: kAvailable,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),

        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          children: [
            Text(
              '$value',

              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label,

              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
