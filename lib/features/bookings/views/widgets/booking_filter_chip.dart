import 'package:flutter/material.dart';
import '../../models/booking_filter.dart';

class BookingFilterChip extends StatelessWidget {
  final String label;
  final BookingFilter value;
  final BookingFilter current;
  final Color color;
  final ValueChanged<BookingFilter> onTap;

  const BookingFilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.current,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
