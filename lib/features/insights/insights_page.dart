import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/shot_theme.dart';
import '../../data/shot_store.dart';
import '../../domain/coffee_order.dart';
import '../../shared/widgets/shot_ui.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final orders = store.orders;
      final rated = orders.where((order) => order.rating != null).toList();
      final averageRating = _averageRating(rated);
      final mostOrderedMenu = _mostOrderedMenu(store);
      final mostVisitedCafe = _mostVisitedCafe(store);
      final trend = _ratingTrend(orders);

      return Scaffold(
        backgroundColor: colors.background,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          children: [
            Text('Stats', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Orders',
                    value: '${orders.length}',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Avg Rating',
                    value:
                        rated.isEmpty ? '-' : averageRating.toStringAsFixed(1),
                    icon: Icons.star_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Top Menu',
                    value: mostOrderedMenu?.label ?? '-',
                    icon: Icons.local_cafe_outlined,
                    sub: mostOrderedMenu == null
                        ? null
                        : '${mostOrderedMenu.count} orders',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Top Cafe',
                    value: mostVisitedCafe?.label ?? '-',
                    icon: Icons.storefront_outlined,
                    sub: mostVisitedCafe == null
                        ? null
                        : '${mostVisitedCafe.count} visits',
                  ),
                ),
              ],
            ),
            const SectionLabel('Rating Trend'),
            ShotCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: trend.length < 2
                  ? Text(
                      'Minimal dua order dengan rating diperlukan untuk menampilkan tren.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trend.length} rated orders',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 178,
                          width: double.infinity,
                          child: _RatingLineChart(points: trend),
                        ),
                      ],
                    ),
            ),
            const SectionLabel('Order Summary'),
            ShotCard(
              surfaceAlt: true,
              child: Row(
                children: [
                  Expanded(
                    child: MiniStat(
                      label: 'Rated',
                      value: '${rated.length}',
                    ),
                  ),
                  Container(width: 1, height: 34, color: colors.border),
                  Expanded(
                    child: MiniStat(
                      label: 'Favorites',
                      value:
                          '${orders.where((order) => order.isFavorite).length}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CountedLabel {
  const _CountedLabel({required this.label, required this.count});

  final String label;
  final int count;
}

class _TrendPoint {
  const _TrendPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class _RatingLineChart extends StatelessWidget {
  const _RatingLineChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);

    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _RatingLineChartPainter(
              points: points,
              colors: colors,
              textStyle: Theme.of(context).textTheme.labelSmall!,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              points.first.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
            const Spacer(),
            Text(
              points.last.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingLineChartPainter extends CustomPainter {
  const _RatingLineChartPainter({
    required this.points,
    required this.colors,
    required this.textStyle,
  });

  final List<_TrendPoint> points;
  final ShotColors colors;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.isEmpty) {
      return;
    }

    final chartRect = Rect.fromLTWH(22, 4, size.width - 22, size.height - 8);
    const minValue = 1.0;
    const maxValue = 5.0;
    const valueRange = maxValue - minValue;

    final gridPaint = Paint()
      ..color = colors.border.withValues(alpha: 0.72)
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final y = chartRect.top + chartRect.height * (i / 4);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    _paintAxisLabel(canvas, '5', chartRect.left - 14, chartRect.top - 6);
    _paintAxisLabel(canvas, '1', chartRect.left - 14, chartRect.bottom - 8);

    final offsets = <Offset>[
      for (var i = 0; i < points.length; i++)
        Offset(
          chartRect.left + chartRect.width * (i / (points.length - 1)),
          chartRect.bottom -
              ((points[i].value - minValue) / valueRange) * chartRect.height,
        ),
    ];

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      linePath.lineTo(offset.dx, offset.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(offsets.last.dx, chartRect.bottom)
      ..lineTo(offsets.first.dx, chartRect.bottom)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.accent.withValues(alpha: 0.18),
            colors.accent.withValues(alpha: 0.02),
          ],
        ).createShader(chartRect),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = colors.primary
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dotPaint = Paint()..color = colors.accent;
    final dotBorderPaint = Paint()..color = colors.surface;
    for (final offset in offsets) {
      canvas.drawCircle(offset, 4.5, dotBorderPaint);
      canvas.drawCircle(offset, 3, dotPaint);
    }
  }

  void _paintAxisLabel(Canvas canvas, String label, double dx, double dy) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle.copyWith(
          color: colors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 18);
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _RatingLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.colors != colors ||
        oldDelegate.textStyle != textStyle;
  }
}

double _averageRating(List<CoffeeOrder> rated) {
  if (rated.isEmpty) {
    return 0;
  }
  final total = rated.fold<int>(0, (sum, order) => sum + order.rating!);
  return total / rated.length;
}

_CountedLabel? _mostOrderedMenu(ShotController store) {
  final counts = <int, int>{};
  for (final order in store.orders) {
    counts.update(order.menuId, (value) => value + 1, ifAbsent: () => 1);
  }
  return _topCount(
    counts,
    (id) => store.menuById(id)?.name,
  );
}

_CountedLabel? _mostVisitedCafe(ShotController store) {
  final counts = <int, int>{};
  for (final order in store.orders) {
    counts.update(order.cafeId, (value) => value + 1, ifAbsent: () => 1);
  }
  return _topCount(
    counts,
    (id) => store.cafeById(id)?.name,
  );
}

_CountedLabel? _topCount(Map<int, int> counts, String? Function(int id) label) {
  if (counts.isEmpty) {
    return null;
  }

  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) {
        return byCount;
      }
      return (label(a.key) ?? '').compareTo(label(b.key) ?? '');
    });
  final top = entries.first;
  return _CountedLabel(label: label(top.key) ?? 'Unknown', count: top.value);
}

List<_TrendPoint> _ratingTrend(List<CoffeeOrder> orders) {
  return orders
      .where((order) => order.rating != null)
      .take(8)
      .toList()
      .reversed
      .map(
        (order) => _TrendPoint(
          label: formatShortDate(order.orderedAt),
          value: order.rating!.clamp(1, 5).toDouble(),
        ),
      )
      .toList();
}
