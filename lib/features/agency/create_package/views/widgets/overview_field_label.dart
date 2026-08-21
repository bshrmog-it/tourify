import 'package:flutter/material.dart';

class OverviewFieldLabel extends StatelessWidget {
  final String text;

  const OverviewFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
