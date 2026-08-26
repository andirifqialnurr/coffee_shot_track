import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ShotDatabase {
  ShotDatabase._({Future<Database> Function()? opener}) : _opener = opener;

  ShotDatabase.test(Future<Database> Function() opener) : _opener = opener;

  static final ShotDatabase instance = ShotDatabase._();
  static const version = 3;

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

  Future<void> close() async {
    final existing = _database;
    if (existing == null) {
      return;
    }
    await existing.close();
    _database = null;
  }
}
