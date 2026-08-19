import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/create_package/cubits/countries/countries_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_state.dart';
import 'package:tourify/features/agency/create_package/views/widgets/day_tab.dart';
import 'package:tourify/features/agency/create_package/views/widgets/overview_tab.dart';
import 'package:tourify/features/agency/create_package/views/widgets/package_hint_sheet.dart';
import 'package:tourify/features/agency/home/views/active_packages_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/create_package/cubits/countries/countries_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_state.dart';
import 'package:tourify/features/agency/create_package/views/widgets/day_tab.dart';
import 'package:tourify/features/agency/create_package/views/widgets/overview_tab.dart';
import 'package:tourify/features/agency/create_package/views/widgets/package_hint_sheet.dart';
import 'package:tourify/features/agency/home/views/active_packages_view.dart';

class AddPackageView extends StatelessWidget {
  const AddPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CountriesCubit()..getCountries()),
        BlocProvider(create: (_) => PackageCreationCubit()),
      ],
      child: const _AddPackageBody(),
    );
  }
}

class _AddPackageBody extends StatefulWidget {
  const _AddPackageBody();

  @override
  State<_AddPackageBody> createState() => _AddPackageBodyState();
}

class _AddPackageBodyState extends State<_AddPackageBody> {
  // 👈 هون بنتتبع هل الـ bottom sheet مفتوحة هلق ولا لأ
  bool _isHintSheetOpen = false;

  void _openHintSheet(BuildContext context) {
    _isHintSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<PackageCreationCubit>(),
          child: const PackageHintSheet(),
        );
      },
    ).whenComplete(() {
      // بينفذ لما الـ sheet تنقفل بأي طريقة (pop يدوي، سحب لتحت، تاب برا الـ sheet...)
      _isHintSheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F7),
      appBar: AppBar(title: const Text('Add New Package')),
      body: BlocConsumer<PackageCreationCubit, PackageCreationState>(
        listenWhen: (previous, current) {
          return previous.status != current.status;
        },

        listener: (context, state) {
          // ============================================================
          // HINT READY → افتح الـ sheet
          // ============================================================

          if (state.status == PackageCreationStatus.hintReady) {
            _openHintSheet(context);
          }

          // ============================================================
          // PACKAGE CREATED SUCCESSFULLY
          // ============================================================

          if (state.status == PackageCreationStatus.success) {
            if (_isHintSheetOpen && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Package added successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );

            Future.delayed(const Duration(milliseconds: 300), () {
              if (!context.mounted) return;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ActivePackagesView()),
              );
            });
          }

          // ============================================================
          // ERROR → هون بالضبط مكان الـ pop يلي بتسأل عنه
          // ============================================================

          if (state.status == PackageCreationStatus.error &&
              state.errorMessage != null) {
            // اقفل الـ bottom sheet الأول، بس إذا كانت فعلاً مفتوحة
            if (_isHintSheetOpen && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!.replaceFirst('Exception: ', ''),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red,
                ),
              );
          }
        },

        builder: (context, state) {
          return Column(
            children: [
              _TabsBar(state: state),
              Expanded(
                child: state.selectedTabIndex == 0
                    ? const OverviewTab()
                    : DayTab(dayIndex: state.selectedTabIndex - 1),
              ),
              _BottomBar(state: state),
            ],
          );
        },
      ),
    );
  }
}
// ====================================================================
// TABS BAR
// ====================================================================

class _TabsBar extends StatelessWidget {
  final PackageCreationState state;

  const _TabsBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PackageCreationCubit>();
    final theme = Theme.of(context);

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TabChip(
              label: 'Overview',
              selected: state.selectedTabIndex == 0,
              onTap: () {
                cubit.selectTab(0);
              },
            ),

            for (var i = 0; i < state.days.length; i++)
              _TabChip(
                label: 'Day ${i + 1}',
                selected: state.selectedTabIndex == i + 1,
                onTap: () {
                  cubit.selectTab(i + 1);
                },
              ),
          ],
        ),
      ),
    );
  }
}
// ====================================================================
// TAB CHIP
// ====================================================================

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          onTap();
        },
        selectedColor: Colors.indigo,
        backgroundColor: const Color(0xFFF0F0F5),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }
}

// ====================================================================
// BOTTOM BAR
// ====================================================================

class _BottomBar extends StatelessWidget {
  final PackageCreationState state;

  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PackageCreationCubit>();

    final loading = state.status == PackageCreationStatus.loadingHint;

    final creating = state.status == PackageCreationStatus.creating;

    final disabled = loading || creating || !cubit.isReadyForHint;
    final theme = Theme.of(context);

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: disabled
              ? null
              : () {
                  cubit.fetchHint();
                },
          child: loading || creating
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
