import 'package:flutter/material.dart';
import 'network_image_thumb.dart';

class PickerGridCard extends StatelessWidget {
  final String? imageUrl;
  final IconData placeholderIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const PickerGridCard({
    super.key,
    required this.imageUrl,
    required this.placeholderIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: NetworkImageThumb(
                url: imageUrl,
                placeholderIcon: placeholderIcon,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
