import 'package:flutter/material.dart';
import '../application/app_controller.dart';

abstract final class Tabs {
  static const home = 0;
  static const collection = 1;
  static const packs = 2;
  static const play = 3;
}

class TabScope extends InheritedNotifier<ValueNotifier<int>> {
  const TabScope({
    super.key,
    required ValueNotifier<int> tab,
    required super.child,
  }) : super(notifier: tab);

  static ValueNotifier<int> of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TabScope>()!.notifier!;
}

void goToTab(BuildContext context, int tab) {
  TabScope.of(context).value = tab;
  Navigator.of(context).popUntil((route) => route.isFirst);
}

Future<void> openPage(
  BuildContext context,
  AppController app,
  Widget Function() page, {
  bool replace = false,
}) {
  final route = MaterialPageRoute<void>(
    builder: (_) =>
        ListenableBuilder(listenable: app, builder: (_, _) => page()),
  );
  final navigator = Navigator.of(context);
  return replace ? navigator.pushReplacement(route) : navigator.push(route);
}
