import 'package:flutter/material.dart';
import 'package:tourify/core/const.dart';

class BookingsEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const BookingsEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: kPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
