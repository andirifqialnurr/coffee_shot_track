import 'coffee_bean.dart';
import 'espresso_shot.dart';

String formatRatio(double doseG, double yieldG) {
  if (doseG <= 0) {
    return '1:0.00';
  }
  return '1:${(yieldG / doseG).toStringAsFixed(2)}';
}

String formatGrams(double value) {
  final isWhole = value == value.roundToDouble();
  return '${isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(1)}g';
}

String formatShotLine(EspressoShot shot) {
  final time = shot.extractionSec == null ? '--s' : '${shot.extractionSec}s';
  return '${formatGrams(shot.doseG)} -> ${formatGrams(shot.yieldG)} * $time * ${formatRatio(shot.doseG, shot.yieldG)}';
}

double averageRating(Iterable<EspressoShot> shots) {
  final rated = shots.where((shot) => shot.rating != null).toList();
  if (rated.isEmpty) {
    return 0;
  }
  final total = rated.fold<int>(0, (sum, shot) => sum + shot.rating!);
  return total / rated.length;
}

EspressoShot? bestShotForBean(Iterable<EspressoShot> shots) {
  final sorted = shots.toList()
    ..sort((a, b) {
      if (a.isFavorite != b.isFavorite) {
        return a.isFavorite ? -1 : 1;
      }

      final ratingCompare = (b.rating ?? 0).compareTo(a.rating ?? 0);
      if (ratingCompare != 0) {
        return ratingCompare;
      }

      return b.brewedAt.compareTo(a.brewedAt);
    });
  return sorted.isEmpty ? null : sorted.first;
}

CoffeeBean? mostUsedBean({
  required Iterable<CoffeeBean> beans,
  required Iterable<EspressoShot> shots,
}) {
  final counts = <int, int>{};
  for (final shot in shots) {
    counts.update(shot.beanId, (count) => count + 1, ifAbsent: () => 1);
  }
  if (counts.isEmpty) {
    return null;
  }

  final topBeanId = counts.entries.reduce((a, b) {
    if (a.value != b.value) {
      return a.value > b.value ? a : b;
    }
    return a.key > b.key ? a : b;
  }).key;

  for (final bean in beans) {
    if (bean.id == topBeanId) {
      return bean;
    }
  }
  return null;
}
