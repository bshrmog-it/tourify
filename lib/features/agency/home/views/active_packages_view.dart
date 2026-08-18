import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/views/pages/add_package_view.dart';

import '../cubit/active_packages_cubit.dart';
import '../cubit/active_packages_state.dart';
import '../models/active_package_model.dart';
import 'package_bookings_view.dart';

const _kPrimary = Color(0xFF0F766E);
const _kPending = Color(0xFFD97706);
const _kConfirmed = Color(0xFF16A34A);
const _kAvailable = Color(0xFF2563EB);
const _kBg = Color(0xFFF6F7FB);
const _kRadius = 18.0;

class ActivePackagesView extends StatelessWidget {
  const ActivePackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivePackagesCubit()..loadActivePackages(),
      child: Scaffold(
        backgroundColor: _kBg,

        appBar: AppBar(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Active Packages',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),

        body: BlocBuilder<ActivePackagesCubit, ActivePackagesState>(
          builder: (context, state) {
            // =========================
            // LOADING
            // =========================

            if (state is ActivePackagesLoading ||
                state is ActivePackagesInitial) {
              return const Center(
                child: CircularProgressIndicator(color: _kPrimary),
              );
            }

            // =========================
            // ERROR
            // =========================

            if (state is ActivePackagesError) {
              return Center(child: Text(state.message));
            }

            // =========================
            // LOADED
            // =========================

            if (state is ActivePackagesLoaded) {
              final packages = state.packages;

              return RefreshIndicator(
                color: _kPrimary,

                onRefresh: () {
                  return context
                      .read<ActivePackagesCubit>()
                      .loadActivePackages();
                },

                child: ListView(
                  padding: const EdgeInsets.all(16),

                  children: [
                    // ==========================================
                    // NO PACKAGES MESSAGE
                    // ==========================================
                    if (packages.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(_kRadius),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 50,
                              color: Colors.black38,
                            ),

                            SizedBox(height: 12),

                            Text(
                              'No active packages',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ==========================================
                    // PACKAGES
                    // ==========================================
                    ...packages.map(
                      (package) => _PackageCard(
                        package: package,

                        onTap: () async {
                          final updated =
                              await Navigator.push<ActivePackageModel>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PackageBookingsView(package: package),
                                ),
                              );

                          if (updated != null && context.mounted) {
                            context.read<ActivePackagesCubit>().updatePackage(
                              updated,
                            );
                          }
                        },
                      ),
                    ),

                    // ==========================================
                    // ADD NEW PACKAGE BUTTON
                    // ==========================================
                    const SizedBox(height: 4),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddPackageView(),
                            ),
                          );
                        },

                        icon: const Icon(Icons.add),

                        label: const Text(
                          'Add New Package',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              );
            }

            // =========================
            // FALLBACK
            // =========================

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ================================================================
// PACKAGE CARD
// ================================================================

class _PackageCard extends StatelessWidget {
  final ActivePackageModel package;
  final VoidCallback onTap;

  const _PackageCard({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_kRadius),

        child: InkWell(
          borderRadius: BorderRadius.circular(_kRadius),
          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // PACKAGE HEADER
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            package.name,

                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
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
                                  color: Colors.grey.shade500,
                                ),

                                const SizedBox(width: 3),

                                Text(
                                  package.countryName!,

                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade600,
                                  ),
                                ),

                                const SizedBox(width: 10),
                              ],

                              Icon(
                                Icons.nights_stay_rounded,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),

                              const SizedBox(width: 3),

                              Text(
                                '${package.numberOfDays} days',

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

                    // ==================================================
                    // PRICE
                    // ==================================================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),

                      decoration: BoxDecoration(
                        color: _kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        '\$${package.price.toStringAsFixed(0)}',

                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _kPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==================================================
                // STATISTICS
                // ==================================================
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
                      color: _kPending,
                    ),

                    const SizedBox(width: 8),

                    _StatChip(
                      label: 'Confirmed',
                      value: package.confirmedCount,
                      color: _kConfirmed,
                    ),

                    const SizedBox(width: 8),

                    _StatChip(
                      label: 'Available',
                      value: package.availableCount,
                      color: _kAvailable,
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

// ================================================================
// STAT CHIP
// ================================================================

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
          color: color.withOpacity(0.1),
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
