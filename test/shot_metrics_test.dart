import 'package:coffee_shot_track/domain/espresso_shot.dart';
import 'package:coffee_shot_track/domain/shot_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatRatio derives yield over dose', () {
    expect(formatRatio(18, 36), '1:2.00');
    expect(formatRatio(19, 42), '1:2.21');
    expect(formatRatio(0, 40), '1:0.00');
  });

  test('bestShotForBean prefers favorite then rating then latest', () {
    final base = DateTime(2026, 8, 25, 9);
    final lowerFavorite = _shot(
      rating: 3,
      favorite: true,
      brewedAt: base.add(const Duration(minutes: 1)),
    );
    final higherRated = _shot(
      rating: 5,
      brewedAt: base.add(const Duration(minutes: 2)),
    );

    expect(bestShotForBean([higherRated, lowerFavorite]), lowerFavorite);

    final olderFive = _shot(rating: 5, brewedAt: base);
    final newerFive = _shot(
      rating: 5,
      brewedAt: base.add(const Duration(minutes: 3)),
    );

    expect(bestShotForBean([olderFive, newerFive]), newerFive);
  });
}

EspressoShot _shot({
  required int rating,
  bool favorite = false,
  required DateTime brewedAt,
}) {
  return EspressoShot(
    id: brewedAt.minute,
    beanId: 1,
    doseG: 18,
    yieldG: 36,
    rating: rating,
    isFavorite: favorite,
    brewedAt: brewedAt,
    createdAt: brewedAt,
    updatedAt: brewedAt,
  );
}
