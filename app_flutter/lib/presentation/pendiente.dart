import 'package:flutter/material.dart';
import 'theme.dart';

class PantallaPendiente extends StatelessWidget {
  final String title;
  final String owner;
  const PantallaPendiente(this.title, {super.key, required this.owner});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: display(28)),
        const SizedBox(height: 8),
        Text('En construcción - $owner', style: body(14, color: Court.muted)),
      ],
    ),
  );
}
