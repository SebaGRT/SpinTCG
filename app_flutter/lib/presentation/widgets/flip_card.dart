import 'dart:math';
import 'package:flutter/material.dart';

/// Gira una carta en 3D: muestra `back` y, al pasar `flipped` a true,
/// voltea en 0,55 s hasta mostrar `front`.
class FlipCard extends StatelessWidget {
  final bool flipped;
  final Widget back;
  final Widget front;
  const FlipCard({
    super.key,
    required this.flipped,
    required this.back,
    required this.front,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: flipped ? 1 : 0),
    duration: const Duration(milliseconds: 550),
    curve: const Cubic(0.2, 0.7, 0.2, 1),
    builder: (context, t, _) {
      final angle = t * pi; // 0 = reverso, π = frente
      final showFront = angle > pi / 2;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspectiva
          ..rotateY(angle),
        child: showFront
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi), // evita verla al revés
                child: front,
              )
            : back,
      );
    },
  );
}
