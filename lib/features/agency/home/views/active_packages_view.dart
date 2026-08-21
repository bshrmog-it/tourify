import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/theme/theme_controller.dart';

import 'package:tourify/features/agency/create_package/views/pages/add_package_view.dart';
import 'package:tourify/features/agency/home/cubit/active_packages_cubit.dart';
import 'package:tourify/features/agency/home/cubit/active_packages_state.dart';
import 'package:tourify/features/agency/home/models/active_package_model.dart';
import 'package:tourify/features/agency/home/views/widgets/active_packages_empty_state.dart';
import 'package:tourify/features/agency/home/views/widgets/package_card.dart';

import 'package_bookings_view.dart';

class ActivePackagesView extends StatelessWidget {
  const ActivePackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => ActivePackagesCubit()..loadActivePackages(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          title: const Text(
            'Active Packages',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
          IconButton(
            tooltip: ThemeController.mode.value == ThemeMode.dark
                ? 'Light mode'
                : 'Dark mode',
            onPressed: () {
              ThemeController.toggle();
            },
            icon: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.mode,
              builder: (context, mode, _) {
                return Icon(
                  mode == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                );
              },
            ),
          ),
          
          const SizedBox(width: 8),
        ],
        ),
        body: BlocBuilder<ActivePackagesCubit, ActivePackagesState>(
          builder: (context, state) {
            if (state is ActivePackagesLoading ||
                state is ActivePackagesInitial) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            if (state is ActivePackagesError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: colors.onSurface),
                ),
              );
            }

            if (state is ActivePackagesLoaded) {
              final packages = state.packages;

              return RefreshIndicator(
                color: colors.primary,
                onRefresh: () =>
                    context.read<ActivePackagesCubit>().loadActivePackages(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (packages.isEmpty) const ActivePackagesEmptyState(),

                    ...packages.map(
                      (package) => PackageCard(
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

                    const SizedBox(height: 4),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddPackageView(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Add New Package',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
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

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
