import 'package:coffee_shot_track/data/shot_store.dart';
import 'package:coffee_shot_track/domain/cafe.dart';
import 'package:coffee_shot_track/domain/coffee_bean.dart';
import 'package:coffee_shot_track/domain/coffee_menu.dart';
import 'package:coffee_shot_track/domain/coffee_order.dart';
import 'package:coffee_shot_track/domain/espresso_shot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seeded controller exposes derived shot state', () {
    final now = DateTime(2026, 8, 25, 11);
    final bean = CoffeeBean(
      id: 1,
      name: 'Rwanda Huye',
      createdAt: now,
      updatedAt: now,
    );
    final shot = EspressoShot(
      id: 1,
      beanId: 1,
      doseG: 18,
      yieldG: 36,
      rating: 5,
      brewedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    final menu = CoffeeMenu(
      id: 1,
      name: 'Americano',
      createdAt: now,
      updatedAt: now,
    );
    final cafe = Cafe(
      id: 1,
      name: 'Home',
      createdAt: now,
      updatedAt: now,
    );
    final order = CoffeeOrder(
      id: 1,
      menuId: 1,
      cafeId: 1,
      beanId: 1,
      orderedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    final controller = ShotController.seeded(
      beans: [bean],
      menus: [menu],
      cafes: [cafe],
      orders: [order],
      shots: [shot],
    );

    expect(controller.activeBeans.single.name, 'Rwanda Huye');
    expect(controller.activeMenus.single.name, 'Americano');
    expect(controller.activeCafes.single.name, 'Home');
    expect(controller.lastOrder, order);
    expect(controller.lastShot, shot);
    expect(controller.totalShots, 1);
    expect(controller.averageRating, 5);
    expect(controller.mostUsedBean, bean);
    expect(controller.bestShotForBean(1), shot);
  });

  test('controller keeps error message on validation failure', () async {
    final controller = ShotController.seeded();

    await expectLater(
      controller.addBean(name: '   '),
      throwsA(isA<ArgumentError>()),
    );

    expect(controller.errorMessage, contains('Bean name is required'));
  });
}
