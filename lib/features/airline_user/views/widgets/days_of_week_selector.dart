import 'package:flutter/material.dart';

class DaysOfWeekSelector extends StatelessWidget {
  final Set<int> selectedDays; // 0=Sunday ... 6=Saturday
  final ValueChanged<int> onToggle;

  const DaysOfWeekSelector({
    super.key,
    required this.selectedDays,
    required this.onToggle,
  });

  static const _labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final selected = selectedDays.contains(index);

        return GestureDetector(
          onTap: () => onToggle(index),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),

            width: 46,
            height: 46,

            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surface,

              shape: BoxShape.circle,

              border: Border.all(
                color: selected ? colors.primary : colors.outline,
              ),
            ),

            child: Text(
              _labels[index],

              style: TextStyle(
                color: selected ? colors.onPrimary : colors.onSurface,

                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    );
  }
}
