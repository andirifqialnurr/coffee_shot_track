import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/coffee_bean.dart';
import '../domain/espresso_shot.dart';
import '../domain/shot_metrics.dart' as metrics;
import 'shot_database.dart';

class ShotStore extends ChangeNotifier {
  ShotStore({ShotDatabase? database}) : _database = database ?? ShotDatabase.instance;

  final ShotDatabase _database;

  bool _isLoading = false;
  String? _errorMessage;
  List<CoffeeBean> _beans = const [];
  List<EspressoShot> _shots = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CoffeeBean> get beans => List.unmodifiable(_beans);
  List<EspressoShot> get shots => List.unmodifiable(_shots);

  List<CoffeeBean> get activeBeans =>
      _beans.where((bean) => bean.status == BeanStatus.active).toList();

  List<EspressoShot> get recentShots => _shots.take(3).toList();

  EspressoShot? get lastShot => _shots.isEmpty ? null : _shots.first;

  int get totalShots => _shots.length;

  double get averageRating => metrics.averageRating(_shots);

  CoffeeBean? get mostUsedBean =>
      metrics.mostUsedBean(beans: _beans, shots: _shots);

  CoffeeBean? get activeOrRecentBean {
    if (activeBeans.isNotEmpty) {
      return activeBeans.first;
    }
    final last = lastShot;
    if (last == null) {
      return _beans.isEmpty ? null : _beans.first;
    }
    return beanById(last.beanId);
  }

  Future<void> load() => _runWithState(refresh);

  Future<void> refresh() async {
    final db = await _database.database;
    final beanRows = await db.query('beans', orderBy: 'updated_at DESC');
    final shotRows = await db.query('shots', orderBy: 'brewed_at DESC');
    _beans = beanRows.map(CoffeeBean.fromMap).toList();
    _shots = shotRows.map(EspressoShot.fromMap).toList();
  }

  CoffeeBean? beanById(int id) {
    for (final bean in _beans) {
      if (bean.id == id) {
        return bean;
      }
    }
    return null;
  }

  List<EspressoShot> shotsForBean(int beanId) {
    return _shots.where((shot) => shot.beanId == beanId).toList();
  }

  EspressoShot? bestShotForBean(int beanId) {
    return metrics.bestShotForBean(shotsForBean(beanId));
  }

  Future<CoffeeBean> addBean({
    required String name,
    String? roaster,
    String? origin,
    String? process,
    String? roastLevel,
    DateTime? roastDate,
    String? notes,
  }) async {
    final now = DateTime.now();
    final bean = CoffeeBean(
      name: name.trim(),
      roaster: _blankToNull(roaster),
      origin: _blankToNull(origin),
      process: _blankToNull(process),
      roastLevel: _blankToNull(roastLevel),
      roastDate: roastDate,
      notes: _blankToNull(notes),
      createdAt: now,
      updatedAt: now,
    );

    return _runMutation(() async {
      final db = await _database.database;
      final id = await db.insert('beans', bean.toMap());
      await refresh();
      return bean.copyWith(id: id);
    });
  }

  Future<void> saveBean(CoffeeBean bean) async {
    final id = bean.id;
    if (id == null) {
      throw ArgumentError('Bean id is required for update.');
    }

    await _runMutation(() async {
      final db = await _database.database;
      await db.update(
        'beans',
        bean.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      await refresh();
    });
  }

  Future<void> markBeanFinished(CoffeeBean bean) {
    return saveBean(bean.copyWith(status: BeanStatus.finished));
  }

  Future<void> deleteBeanOrArchive(CoffeeBean bean) async {
    final id = bean.id;
    if (id == null) {
      return;
    }

    await _runMutation(() async {
      final db = await _database.database;
      final count = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM shots WHERE bean_id = ?',
              [id],
            ),
          ) ??
          0;

      if (count > 0) {
        await db.update(
          'beans',
          bean
              .copyWith(status: BeanStatus.finished, updatedAt: DateTime.now())
              .toMap(),
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        await db.delete('beans', where: 'id = ?', whereArgs: [id]);
      }
      await refresh();
    });
  }

  Future<EspressoShot> addShot(EspressoShot shot) async {
    return _runMutation(() async {
      _validateShot(shot);
      final db = await _database.database;
      final id = await db.insert('shots', shot.toMap());
      await refresh();
      return shot.copyWith(id: id);
    });
  }

  Future<void> saveShot(EspressoShot shot) async {
    final id = shot.id;
    if (id == null) {
      throw ArgumentError('Shot id is required for update.');
    }

    await _runMutation(() async {
      _validateShot(shot);
      final db = await _database.database;
      await db.update(
        'shots',
        shot.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      await refresh();
    });
  }

  Future<void> deleteShot(EspressoShot shot) async {
    final id = shot.id;
    if (id == null) {
      return;
    }

    await _runMutation(() async {
      final db = await _database.database;
      await db.delete('shots', where: 'id = ?', whereArgs: [id]);
      await refresh();
    });
  }

  Future<void> toggleFavorite(EspressoShot shot) {
    return saveShot(shot.copyWith(isFavorite: !shot.isFavorite));
  }

  Future<T> _runMutation<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      _errorMessage = null;
      notifyListeners();
      return result;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _runWithState(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

void _validateShot(EspressoShot shot) {
  if (shot.doseG <= 0) {
    throw ArgumentError('Dose must be greater than 0.');
  }
  if (shot.yieldG < 0) {
    throw ArgumentError('Yield cannot be negative.');
  }
  final rating = shot.rating;
  if (rating != null && (rating < 1 || rating > 5)) {
    throw ArgumentError('Rating must be between 1 and 5.');
  }
}
