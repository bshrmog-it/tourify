import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_state.dart';
import 'hint_row.dart';

class PackageHintSheet extends StatefulWidget {
  const PackageHintSheet({super.key});

  @override
  State<PackageHintSheet> createState() => _PackageHintSheetState();
}

class _PackageHintSheetState extends State<PackageHintSheet> {
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final hint = context.read<PackageCreationCubit>().state.hint;

    if (hint != null) {
      priceController.text = hint.suggestedMinPrice.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final cubit = context.read<PackageCreationCubit>();
    final state = context.watch<PackageCreationCubit>().state;
    final hint = state.hint;
    final creating = state.status == PackageCreationStatus.creating;

    if (hint == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: colors.surface,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // TITLE
            // ============================================================
            Text(
              'Cost Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // ============================================================
            // COST DETAILS
            // ============================================================
            HintRow('Hotels total', hint.hotelTotalCost),

            HintRow('Flights total', hint.flightTotalCost),

            HintRow('Total cost', hint.totalCost),

            HintRow('Cost per person (no profit)', hint.costWithoutProfit),

            HintRow(
              'Suggested price / person',
              hint.suggestedMinPrice,
              highlight: true,
            ),

            const SizedBox(height: 16),

            // ============================================================
            // PRICE
            // ============================================================
            Text(
              'Cost per person',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
                hintText: 'Enter price per person',
                hintStyle: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // BUTTONS
            // ============================================================
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: creating
                        ? null
                        : () {
                            cubit.backToEdit();
                            Navigator.pop(context);
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.outline),
                    ),
                    child: const Text('Back & Edit'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                    onPressed: creating
                        ? null
                        : () {
                            final price = double.tryParse(priceController.text);

                            if (price != null) {
                              cubit.confirmAndCreate(price);
                            }
                          },
                    child: creating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Text('Create Package'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
