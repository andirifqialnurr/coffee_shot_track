import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ShotDatabase {
  ShotDatabase._({Future<Database> Function()? opener}) : _opener = opener;

  ShotDatabase.test(Future<Database> Function() opener) : _opener = opener;

  static final ShotDatabase instance = ShotDatabase._();

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
      version: 1,
      onCreate: (database, version) => createSchema(database),
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
