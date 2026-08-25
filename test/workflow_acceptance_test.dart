import 'package:coffee_shot_track/app/shot_theme.dart';
import 'package:coffee_shot_track/data/shot_store.dart';
import 'package:coffee_shot_track/domain/coffee_bean.dart';
import 'package:coffee_shot_track/domain/espresso_shot.dart';
import 'package:coffee_shot_track/features/history/history_page.dart';
import 'package:coffee_shot_track/features/shots/shot_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart' as shad;

void main() {
  tearDown(Get.reset);

  testWidgets('shot form updates ratio when dose and yield change', (
    tester,
  ) async {
    final controller = ShotController.seeded(
      beans: [_bean(id: 1, name: 'Ethiopia Halo')],
    );

    await tester.pumpWidget(
      _wrap(controller, const ShotFormPage(initialBeanId: 1)),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const ValueKey('param-Dose in')), '18');
    await tester.enterText(find.byKey(const ValueKey('param-Yield out')), '36');
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('BREW RATIO'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('1 : 2.00'), findsOneWidget);
  });

  testWidgets('history filters shots by bean', (tester) async {
    final controller = ShotController.seeded(
      beans: [
        _bean(id: 1, name: 'Kenya Nyeri'),
        _bean(id: 2, name: 'Brazil Cerrado'),
      ],
      shots: [
        _shot(id: 1, beanId: 1, dose: 18, yieldOut: 36, rating: 4),
        _shot(id: 2, beanId: 2, dose: 19, yieldOut: 38, rating: 5),
      ],
    );

    await tester.pumpWidget(_wrap(controller, const HistoryPage()));
    await tester.pump();

    expect(find.text('18.0g -> 36.0g * 28s'), findsOneWidget);
    expect(find.text('19.0g -> 38.0g * 28s'), findsOneWidget);

    await tester.tap(find.text('Semua Bean'));
    await tester.pump();
    await tester.tap(find.text('Brazil Cerrado').first);
    await tester.pump();

    expect(find.text('18.0g -> 36.0g * 28s'), findsNothing);
    expect(find.text('19.0g -> 38.0g * 28s'), findsOneWidget);
  });
}

Widget _wrap(ShotController controller, Widget child) {
  Get.put<ShotController>(controller);

  return MaterialApp(
    theme: ShotTheme.light(),
    home: Scaffold(body: child),
    localizationsDelegates: const [
      shad.GlobalShadLocalizations.delegate,
    ],
    builder: (context, child) => shad.ShadTheme(
      data: ShotTheme.shadLight(),
      child: child ?? const SizedBox.shrink(),
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
