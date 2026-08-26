import 'dart:io';

import 'package:coffee_shot_track/data/shot_database.dart';
import 'package:coffee_shot_track/data/shot_store.dart';
import 'package:coffee_shot_track/domain/cafe.dart';
import 'package:coffee_shot_track/domain/coffee_bean.dart';
import 'package:coffee_shot_track/domain/coffee_menu.dart';
import 'package:coffee_shot_track/domain/coffee_order.dart';
import 'package:coffee_shot_track/domain/espresso_shot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory tempDir;
  late String dbPath;
  late ShotDatabase database;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('shot_store_test_');
    dbPath = '${tempDir.path}/shot_tracker_test.db';
    database = ShotDatabase.test(
      () => databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: ShotDatabase.version,
          onCreate: (db, version) => ShotDatabase.createSchema(db),
        ),
      ),
    );
  });

  tearDown(() async {
    await database.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('beans and shots are read back after a store restart', () async {
    final firstSession = ShotController(database: database);
    await firstSession.load();

    final bean = await firstSession.addBean(
      name: 'Ethiopia Bombe',
      roaster: 'Home Roaster',
      roastLevel: 'Light',
      imagePath: 'local/bean.jpg',
    );
    await firstSession.addShot(
      _shot(beanId: bean.id!, dose: 18, yieldOut: 42, rating: 5),
    );

    final secondSession = ShotController(database: database);
    await secondSession.load();

    expect(secondSession.beans.single.name, 'Ethiopia Bombe');
    expect(secondSession.beans.single.imagePath, 'local/bean.jpg');
    expect(secondSession.shots.single.beanId, bean.id);
    expect(secondSession.shots.single.ratio, closeTo(2.333, 0.001));
  });

  test('brew again copy does not mutate the source shot', () async {
    final store = ShotController(database: database);
    await store.load();
    final bean = await store.addBean(name: 'Colombia Pink Bourbon');
    final source = await store.addShot(
      _shot(
        beanId: bean.id!,
        dose: 18,
        yieldOut: 36,
        rating: 5,
        notes: 'Sweet orange',
      ),
    );

    final replay = source.duplicateForBrewAgain();
    await store.addShot(replay.copyWith(yieldG: 38, rating: 4));

    final unchangedSource = store.shots.firstWhere((shot) => shot.id == source.id);
    expect(unchangedSource.yieldG, 36);
    expect(unchangedSource.rating, 5);
    expect(unchangedSource.tastingNotes, 'Sweet orange');
    expect(store.shots.length, 2);
  });

  test('bean with shots is archived instead of deleted', () async {
    final store = ShotController(database: database);
    await store.load();
    final bean = await store.addBean(name: 'Brazil Cerrado');
    await store.addShot(_shot(beanId: bean.id!, dose: 19, yieldOut: 38));

    await store.deleteBeanOrArchive(bean);

    expect(store.beans.single.status, BeanStatus.finished);
    expect(store.shots.single.beanId, bean.id);
  });

  test('store rejects invalid bean and shot values', () async {
    final store = ShotController(database: database);
    await store.load();

    await expectLater(
      store.addBean(name: '   '),
      throwsA(isA<ArgumentError>()),
    );

    final bean = await store.addBean(name: 'Kenya Nyeri');
    await expectLater(
      store.addShot(_shot(beanId: bean.id!, dose: 0, yieldOut: 35)),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      store.addShot(_shot(beanId: bean.id!, dose: 18, yieldOut: -1)),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('default and custom menus persist locally', () async {
    final firstSession = ShotController(database: database);
    await firstSession.load();

    expect(firstSession.menus.map((menu) => menu.name), contains('Americano'));

    final custom = await firstSession.addMenu(
      name: 'Iced Long Black',
      category: 'Espresso-based',
      description: 'Espresso over cold water and ice',
      imagePath: 'local/menu.jpg',
    );

    final secondSession = ShotController(database: database);
    await secondSession.load();

    expect(
      secondSession.menus.map((menu) => menu.name),
      contains('Iced Long Black'),
    );
    expect(secondSession.menuById(custom.id!)?.imagePath, 'local/menu.jpg');

    await secondSession.archiveMenu(custom);
    expect(
      secondSession.menuById(custom.id!)?.status,
      MenuStatus.archived,
    );
  });

  test('default and custom cafes persist locally', () async {
    final firstSession = ShotController(database: database);
    await firstSession.load();

    expect(firstSession.cafes.map((cafe) => cafe.name), contains('Home'));

    final custom = await firstSession.addCafe(
      name: 'Kawan Kopi',
      area: 'Bandung',
      address: 'Jl. Kopi No. 1',
      imagePath: 'local/cafe.jpg',
    );

    final secondSession = ShotController(database: database);
    await secondSession.load();

    expect(secondSession.cafes.map((cafe) => cafe.name), contains('Kawan Kopi'));
    expect(secondSession.cafeById(custom.id!)?.imagePath, 'local/cafe.jpg');

    await secondSession.archiveCafe(custom);
    expect(
      secondSession.cafeById(custom.id!)?.status,
      CafeStatus.archived,
    );
  });

  test('orders require menu and cafe but allow unknown bean', () async {
    final store = ShotController(database: database);
    await store.load();
    final menu = store.menus.firstWhere((item) => item.name == 'Americano');
    final cafe = store.cafes.firstWhere((item) => item.name == 'Home');
    final now = DateTime(2026, 8, 26, 12);

    await expectLater(
      store.addOrder(
        CoffeeOrder(
          menuId: 0,
          cafeId: cafe.id!,
          orderedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );

    final order = await store.addOrder(
      CoffeeOrder(
        menuId: menu.id!,
        cafeId: cafe.id!,
        imagePath: 'local/order.jpg',
        rating: 4,
        tastingNotes: 'Clean and sweet',
        orderedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(order.beanId, isNull);
    expect(order.imagePath, 'local/order.jpg');
    expect(store.orders.single.menuId, menu.id);
    expect(store.orders.single.cafeId, cafe.id);
  });

  test('legacy shots can be migrated into orders', () async {
    final store = ShotController(database: database);
    await store.load();
    final bean = await store.addBean(name: 'Legacy Bean');
    final shot = await store.addShot(
      _shot(beanId: bean.id!, dose: 18, yieldOut: 36, rating: 5),
    );

    final db = await database.database;
    await ShotDatabase.migrateLegacyShotsToOrders(db);
    await store.refresh();

    final migrated = store.orders.singleWhere(
      (order) => order.legacyShotId == shot.id,
    );
    expect(migrated.beanId, bean.id);
    expect(migrated.ratio, 2);
    expect(store.menuById(migrated.menuId)?.name, 'Espresso');
    expect(store.cafeById(migrated.cafeId)?.name, 'Home');
  });
}

EspressoShot _shot({
  required int beanId,
  required double dose,
  required double yieldOut,
  int? rating,
  String? notes,
}) {
  final now = DateTime(2026, 8, 25, 8);
  return EspressoShot(
    beanId: beanId,
    doseG: dose,
    yieldG: yieldOut,
    extractionSec: 28,
    grindSetting: '12 clicks',
    rating: rating,
    tastingNotes: notes,
    brewedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}
