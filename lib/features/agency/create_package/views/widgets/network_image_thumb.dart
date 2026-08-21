import 'package:flutter/material.dart';

class NetworkImageThumb extends StatelessWidget {
  final String? url;
  final IconData placeholderIcon;

  const NetworkImageThumb({
    super.key,
    required this.url,
    required this.placeholderIcon,
  });

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        placeholderIcon,
        size: 38,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder(context);

    return Image.network(
      url!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, _, __) => _placeholder(context),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
