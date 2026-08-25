import 'package:flutter/widgets.dart';

import '../data/shot_store.dart';

class ShotScope extends InheritedNotifier<ShotStore> {
  const ShotScope({
    super.key,
    required ShotStore store,
    required super.child,
  }) : super(notifier: store);

  static ShotStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShotScope>();
    assert(scope != null, 'ShotScope not found in context.');
    return scope!.notifier!;
  }
}
