import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/cubits/countries/countries_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_state.dart';
import 'package:tourify/features/agency/home/views/active_packages_view.dart';
import '../widgets/day_tab.dart';
import '../widgets/overview_tab.dart';
import '../widgets/package_hint_sheet.dart';
import '../widgets/tabs_bar.dart';
import '../widgets/create_bottom_bar.dart';

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
  bool _isHintSheetOpen = false;

  void _openHintSheet(BuildContext context) {
    _isHintSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PackageCreationCubit>(),
        child: const PackageHintSheet(),
      ),
    ).whenComplete(() => _isHintSheetOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Add New Package')),
      body: BlocConsumer<PackageCreationCubit, PackageCreationState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == PackageCreationStatus.hintReady) {
            _openHintSheet(context);
          }

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

          if (state.status == PackageCreationStatus.error &&
              state.errorMessage != null) {
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
                  backgroundColor: theme.colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              TabsBar(state: state),
              Expanded(
                child: state.selectedTabIndex == 0
                    ? const OverviewTab()
                    : DayTab(dayIndex: state.selectedTabIndex - 1),
              ),
              CreateBottomBar(state: state),
            ],
          );
        },
      ),
    );
  }
}
