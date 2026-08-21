import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_state.dart';

class TabsBar extends StatelessWidget {
  final PackageCreationState state;

  const TabsBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PackageCreationCubit>();

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TabChip(
              label: 'Overview',
              selected: state.selectedTabIndex == 0,
              onTap: () => cubit.selectTab(0),
            ),
            for (var i = 0; i < state.days.length; i++)
              _TabChip(
                label: 'Day ${i + 1}',
                selected: state.selectedTabIndex == i + 1,
                onTap: () => cubit.selectTab(i + 1),
              ),
          ],
        ),
      ),
    );
  }
}

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
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: selected
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }
}
