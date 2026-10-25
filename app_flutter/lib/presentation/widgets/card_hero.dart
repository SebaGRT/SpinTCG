import 'package:flutter/material.dart';

class CardHero extends StatelessWidget {
  final String id;
  final Widget child;
  const CardHero({super.key, required this.id, required this.child});

  @override
  Widget build(BuildContext context) =>
      Hero(tag: 'carta-$id', flightShuttleBuilder: _shuttle, child: child);

  static Widget _shuttle(
    BuildContext flight,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext from,
    BuildContext to,
  ) {
    final detail = direction == HeroFlightDirection.push ? to : from;
    final size = (detail.findRenderObject()! as RenderBox).size;
    return FittedBox(
      child: SizedBox.fromSize(
        size: size,
        child: Material(
          type: MaterialType.transparency,
          child: (detail.widget as Hero).child,
        ),
      ),
    );
  }
}
