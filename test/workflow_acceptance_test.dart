import 'package:coffee_shot_track/app/shot_scope.dart';
import 'package:coffee_shot_track/app/shot_theme.dart';
import 'package:coffee_shot_track/data/shot_store.dart';
import 'package:coffee_shot_track/domain/coffee_bean.dart';
import 'package:coffee_shot_track/domain/espresso_shot.dart';
import 'package:coffee_shot_track/features/history/history_page.dart';
import 'package:coffee_shot_track/features/shots/shot_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shot form updates ratio when dose and yield change', (
    tester,
  ) async {
    final store = ShotStore.seeded(beans: [_bean(id: 1, name: 'Ethiopia Halo')]);

    await tester.pumpWidget(
      _wrap(store, const ShotFormPage(initialBeanId: 1)),
    );
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextFormField, 'Dose in'), '18');
    await tester.enterText(find.widgetWithText(TextFormField, 'Yield out'), '36');
    await tester.pump();

    expect(find.text('1:2.00'), findsOneWidget);
  });

  testWidgets('history filters shots by bean', (tester) async {
    final store = ShotStore.seeded(
      beans: [
        _bean(id: 1, name: 'Kenya Nyeri'),
        _bean(id: 2, name: 'Brazil Cerrado'),
      ],
      shots: [
        _shot(id: 1, beanId: 1, dose: 18, yieldOut: 36, rating: 4),
        _shot(id: 2, beanId: 2, dose: 19, yieldOut: 38, rating: 5),
      ],
    );

    await tester.pumpWidget(_wrap(store, const HistoryPage()));
    await tester.pump();

    expect(find.text('Kenya Nyeri'), findsOneWidget);
    expect(find.text('Brazil Cerrado'), findsOneWidget);

    await tester.tap(find.text('All beans'));
    await tester.pump();
    await tester.tap(find.text('Brazil Cerrado').last);
    await tester.pump();

    expect(find.text('Kenya Nyeri'), findsNothing);
    expect(find.text('Brazil Cerrado'), findsWidgets);
  });
}

Widget _wrap(ShotStore store, Widget child) {
  return ShotScope(
    store: store,
    child: MaterialApp(
      theme: ShotTheme.light(),
      home: Scaffold(body: child),
    ),
  );
}

CoffeeBean _bean({required int id, required String name}) {
  final now = DateTime(2026, 8, 25, 10);
  return CoffeeBean(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
  );
}

EspressoShot _shot({
  required int id,
  required int beanId,
  required double dose,
  required double yieldOut,
  int? rating,
}) {
  final now = DateTime(2026, 8, 25, 10).add(Duration(minutes: id));
  return EspressoShot(
    id: id,
    beanId: beanId,
    doseG: dose,
    yieldG: yieldOut,
    extractionSec: 28,
    rating: rating,
    brewedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}
