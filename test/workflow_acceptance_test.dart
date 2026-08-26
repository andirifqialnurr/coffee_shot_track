import 'package:coffee_shot_track/app/shot_theme.dart';
import 'package:coffee_shot_track/data/shot_store.dart';
import 'package:coffee_shot_track/domain/cafe.dart';
import 'package:coffee_shot_track/domain/coffee_bean.dart';
import 'package:coffee_shot_track/domain/coffee_menu.dart';
import 'package:coffee_shot_track/domain/coffee_order.dart';
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

  testWidgets('history filters orders by menu', (tester) async {
    final controller = ShotController.seeded(
      beans: [
        _bean(id: 1, name: 'Kenya Nyeri'),
        _bean(id: 2, name: 'Brazil Cerrado'),
      ],
      menus: [
        _menu(id: 1, name: 'Iced Americano'),
        _menu(id: 2, name: 'Piccolo'),
      ],
      cafes: [
        _cafe(id: 1, name: 'Home Bar'),
        _cafe(id: 2, name: 'Roastery Lab'),
      ],
      orders: [
        _order(id: 1, menuId: 1, cafeId: 1, beanId: 1, rating: 4),
        _order(id: 2, menuId: 2, cafeId: 2, beanId: 2, rating: 5),
      ],
    );

    await tester.pumpWidget(_wrap(controller, const HistoryPage()));
    await tester.pump();

    expect(find.text('Home Bar - Kenya Nyeri'), findsOneWidget);
    expect(find.text('Roastery Lab - Brazil Cerrado'), findsOneWidget);

    await tester.tap(find.byTooltip('Filter History'));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .ancestor(of: find.text('Piccolo'), matching: find.byType(InkWell))
          .last,
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Home Bar - Kenya Nyeri'), findsNothing);
    expect(find.text('Roastery Lab - Brazil Cerrado'), findsOneWidget);
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

CoffeeMenu _menu({required int id, required String name}) {
  final now = DateTime(2026, 8, 25, 10);
  return CoffeeMenu(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
  );
}

Cafe _cafe({required int id, required String name}) {
  final now = DateTime(2026, 8, 25, 10);
  return Cafe(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
  );
}

CoffeeOrder _order({
  required int id,
  required int menuId,
  required int cafeId,
  int? beanId,
  int? rating,
}) {
  final now = DateTime(2026, 8, 25, 10).add(Duration(minutes: id));
  return CoffeeOrder(
    id: id,
    menuId: menuId,
    cafeId: cafeId,
    beanId: beanId,
    rating: rating,
    orderedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}
