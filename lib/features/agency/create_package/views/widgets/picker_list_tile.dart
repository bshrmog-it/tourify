import 'package:flutter/material.dart';

class PickerListTile extends StatelessWidget {
  final String? imageUrl;
  final IconData placeholderIcon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const PickerListTile({
    super.key,
    required this.imageUrl,
    required this.placeholderIcon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
          : Icon(placeholderIcon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}
