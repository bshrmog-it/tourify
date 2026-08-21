import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PickerScaffold<C extends Cubit<S>, S> extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext, S) builder;

  const PickerScaffold({super.key, required this.title, required this.builder});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(child: BlocBuilder<C, S>(builder: builder)),
          ],
        );
      },
    );
  }
}
