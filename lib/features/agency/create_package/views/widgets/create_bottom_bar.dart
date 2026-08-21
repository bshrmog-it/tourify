import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_state.dart';

class CreateBottomBar extends StatelessWidget {
  final PackageCreationState state;

  const CreateBottomBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PackageCreationCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final loading = state.status == PackageCreationStatus.loadingHint;
    final creating = state.status == PackageCreationStatus.creating;
    final disabled = loading || creating || !cubit.isReadyForHint;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            disabledForegroundColor: colorScheme.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: disabled ? null : () => cubit.fetchHint(),
          child: loading || creating
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  'Create',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
