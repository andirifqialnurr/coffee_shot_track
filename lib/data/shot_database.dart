import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ShotDatabase {
  ShotDatabase._({Future<Database> Function()? opener}) : _opener = opener;

  ShotDatabase.test(Future<Database> Function() opener) : _opener = opener;

  static final ShotDatabase instance = ShotDatabase._();
  static const version = 4;

  final Future<Database> Function()? _opener;
  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final customOpener = _opener;
    if (customOpener != null) {
      final db = await customOpener();
      _database = db;
      return db;
    }

    final path = p.join(await getDatabasesPath(), 'shot_tracker.db');
    final db = await openDatabase(
      path,
      version: version,
      onCreate: (database, version) => createSchema(database),
      onUpgrade: (database, oldVersion, newVersion) =>
          upgradeSchema(database, oldVersion, newVersion),
    );

    _database = db;
    return db;
  }

  static Future<void> createSchema(Database database) async {
    await database.execute('''
          CREATE TABLE beans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            roaster TEXT,
            origin TEXT,
            process TEXT,
            roast_level TEXT,
            roast_date TEXT,
            notes TEXT,
            status TEXT NOT NULL DEFAULT 'active',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

    await database.execute('''
          CREATE TABLE shots (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bean_id INTEGER NOT NULL,
            dose_g REAL NOT NULL,
            yield_g REAL NOT NULL,
            extraction_sec INTEGER,
            temperature_c REAL,
            grind_setting TEXT,
            rating INTEGER,
            tasting_notes TEXT,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            brewed_at TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(bean_id) REFERENCES beans(id)
          )
        ''');

    await database.execute(
      'CREATE INDEX idx_shots_bean_id ON shots(bean_id)',
    );
    await database.execute(
      'CREATE INDEX idx_shots_brewed_at ON shots(brewed_at DESC)',
    );
    await database.execute('CREATE INDEX idx_beans_status ON beans(status)');
    await _createMenusSchema(database);
    await seedDefaultMenus(database);
    await _createCafesSchema(database);
    await seedDefaultCafes(database);
    await _createOrdersSchema(database);
    await migrateLegacyShotsToOrders(database);
  }

  static Future<void> upgradeSchema(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createMenusSchema(database);
      await seedDefaultMenus(database);
    }
    if (oldVersion < 3) {
      await _createCafesSchema(database);
      await seedDefaultCafes(database);
    }
    if (oldVersion < 4) {
      await seedDefaultMenus(database);
      await seedDefaultCafes(database);
      await _createOrdersSchema(database);
      await migrateLegacyShotsToOrders(database);
    }
  }

  static Future<void> _createMenusSchema(Database database) async {
    await database.execute('''
          CREATE TABLE IF NOT EXISTS menus (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            category TEXT,
            description TEXT,
            notes TEXT,
            image_path TEXT,
            status TEXT NOT NULL DEFAULT 'active',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_menus_status ON menus(status)',
    );
  }

  static Future<void> seedDefaultMenus(Database database) async {
    final now = DateTime.now().toIso8601String();
    final menus = [
      ('Espresso', 'Espresso-based', 'Classic concentrated coffee'),
      ('Americano', 'Espresso-based', 'Espresso with hot water'),
      ('Latte', 'Milk-based', 'Espresso with steamed milk'),
      ('Cappuccino', 'Milk-based', 'Espresso, milk, and foam'),
      ('V60', 'Manual brew', 'Pour-over filter coffee'),
      ('Aeropress', 'Manual brew', 'Immersion-pressure brewed coffee'),
      ('Japanese Iced Coffee', 'Manual brew', 'Hot brew over ice'),
      ('Manual Brew', 'Manual brew', 'General non-espresso brew'),
      ('Signature Drink', 'Signature', 'Cafe signature coffee menu'),
    ];

    for (final (name, category, description) in menus) {
      await database.insert(
        'menus',
        {
          'name': name,
          'category': category,
          'description': description,
          'status': 'active',
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> _createCafesSchema(Database database) async {
    await database.execute('''
          CREATE TABLE IF NOT EXISTS cafes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            area TEXT,
            address TEXT,
            notes TEXT,
            image_path TEXT,
            status TEXT NOT NULL DEFAULT 'active',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_cafes_status ON cafes(status)',
    );
  }

  static Future<void> seedDefaultCafes(Database database) async {
    final now = DateTime.now().toIso8601String();
    await database.insert(
      'cafes',
      {
        'name': 'Home',
        'area': 'Personal brew',
        'notes': 'Default place for coffee made or logged at home.',
        'status': 'active',
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> _createOrdersSchema(Database database) async {
    await database.execute('''
          CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            menu_id INTEGER NOT NULL,
            cafe_id INTEGER NOT NULL,
            bean_id INTEGER,
            legacy_shot_id INTEGER UNIQUE,
            image_path TEXT,
            price REAL,
            rating INTEGER,
            tasting_notes TEXT,
            dose_g REAL,
            yield_g REAL,
            extraction_sec INTEGER,
            temperature_c REAL,
            grind_setting TEXT,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            ordered_at TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(menu_id) REFERENCES menus(id),
            FOREIGN KEY(cafe_id) REFERENCES cafes(id),
            FOREIGN KEY(bean_id) REFERENCES beans(id)
          )
        ''');

    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_menu_id ON orders(menu_id)',
    );
    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_cafe_id ON orders(cafe_id)',
    );
    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_bean_id ON orders(bean_id)',
    );
    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_ordered_at '
      'ON orders(ordered_at DESC)',
    );
  }

  static Future<void> migrateLegacyShotsToOrders(Database database) async {
    final hasShots = await _tableExists(database, 'shots');
    if (!hasShots) {
      return;
    }

    final espressoMenuId = await _idForName(database, 'menus', 'Espresso');
    final homeCafeId = await _idForName(database, 'cafes', 'Home');
    if (espressoMenuId == null || homeCafeId == null) {
      return;
    }

    final shotRows = await database.query('shots', orderBy: 'brewed_at ASC');
    for (final shot in shotRows) {
      await database.insert(
        'orders',
        {
          'menu_id': espressoMenuId,
          'cafe_id': homeCafeId,
          'bean_id': shot['bean_id'],
          'legacy_shot_id': shot['id'],
          'rating': shot['rating'],
          'tasting_notes': shot['tasting_notes'],
          'dose_g': shot['dose_g'],
          'yield_g': shot['yield_g'],
          'extraction_sec': shot['extraction_sec'],
          'temperature_c': shot['temperature_c'],
          'grind_setting': shot['grind_setting'],
          'is_favorite': shot['is_favorite'] ?? 0,
          'ordered_at': shot['brewed_at'],
          'created_at': shot['created_at'],
          'updated_at': shot['updated_at'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<int?> _idForName(
    Database database,
    String table,
    String name,
  ) async {
    final rows = await database.query(
      table,
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['id'] as int;
  }

  static Future<bool> _tableExists(Database database, String table) async {
    final rows = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [table],
    );
    return rows.isNotEmpty;
  }

  Future<void> close() async {
    final existing = _database;
    if (existing == null) {
      return;
    }
    await existing.close();
    _database = null;
  }
}
