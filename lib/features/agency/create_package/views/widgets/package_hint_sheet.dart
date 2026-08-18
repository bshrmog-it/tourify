import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_state.dart';

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
    final cubit = context.read<PackageCreationCubit>();
    final state = context.watch<PackageCreationCubit>().state;
    final hint = state.hint;
    final creating = state.status == PackageCreationStatus.creating;

    if (hint == null) return const SizedBox.shrink();

    return Padding(
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
          const Text(
            'ملخص التكلفة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _HintRow('Hotels total', hint.hotelTotalCost),
          _HintRow('Flights total', hint.flightTotalCost),
          _HintRow('Total cost', hint.totalCost),
          _HintRow('Cost per person (no profit)', hint.costWithoutProfit),
          _HintRow(
            'Suggested price / person',
            hint.suggestedMinPrice,
            highlight: true,
          ),
          const SizedBox(height: 16),
          const Text(
            'سعر الباقة للشخص الواحد',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
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
                  child: const Text('رجوع وتعديل'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                  onPressed: creating
                      ? null
                      : () {
                          final price = double.tryParse(priceController.text);
                          if (price != null) cubit.confirmAndCreate(price);
                        },
                  child: creating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'تأكيد',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final String label;
  final double value;
  final bool highlight;
  const _HintRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value.toStringAsFixed(0),
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.indigo : null,
            ),
          ),
        ],
      ),
    );
  }
}
