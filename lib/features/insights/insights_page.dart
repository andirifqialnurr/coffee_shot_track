import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/shot_theme.dart';
import '../../data/shot_store.dart';
import '../../domain/espresso_shot.dart';
import '../../shared/widgets/shot_ui.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final rated = store.shots.where((shot) => shot.rating != null).toList();
      final activeBean = store.activeOrRecentBean;
      final activeBeanShots = activeBean == null
          ? <EspressoShot>[]
          : store.shotsForBean(activeBean.id!);
      final highlightPool = _topRatedPool(activeBeanShots);
      final mostUsedBean = store.mostUsedBean;
      final mostUsedCount = mostUsedBean == null
          ? 0
          : store.shotsForBean(mostUsedBean.id!).length;
      final trend = _ratioTrend(store.shots);

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
                    label: 'Total Shots',
                    value: '${store.totalShots}',
                    icon: Icons.local_cafe_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Avg Rating',
                    value: rated.isEmpty
                        ? '-'
                        : store.averageRating.toStringAsFixed(1),
                    icon: Icons.star_rounded,
                  ),
                ),
              ],
            ),
            const SectionLabel('Brew Ratio Trend'),
            ShotCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: trend.length < 2
                  ? Text(
                      'Minimal dua shot diperlukan untuk menampilkan tren.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${trend.length} shot terakhir',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: colors.textSecondary),
                              ),
                            ),
                            Text(
                              '1 : ${trend.last.ratio.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: colors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 172,
                          width: double.infinity,
                          child: _RatioLineChart(points: trend),
                        ),
                      ],
                    ),
            ),
            const SectionLabel('Bean Usage'),
            StatCard(
              label: 'Most-used Bean',
              value: mostUsedBean?.name ?? '-',
              icon: Icons.eco_outlined,
              sub: mostUsedBean == null ? null : '$mostUsedCount shots dicatat',
            ),
            const SectionLabel('Active Bean Highlight'),
            if (activeBean == null || highlightPool.isEmpty)
              ShotCard(
                surfaceAlt: true,
                child: Text(
                  'Data belum cukup untuk menampilkan highlight time dan ratio.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              )
            else
              ShotCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 16,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${activeBean.name} shot terbaik',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: colors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MiniStat(
                            label: 'Extraction time',
                            value: _timeRange(highlightPool),
                          ),
                        ),
                        Container(width: 1, height: 34, color: colors.border),
                        Expanded(
                          child: MiniStat(
                            label: 'Ratio',
                            value: _ratioRange(highlightPool),
                          ),
                        ),
                      ],
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

class _TrendPoint {
  const _TrendPoint({
    required this.label,
    required this.ratio,
  });

  final String label;
  final double ratio;
}

class _RatioLineChart extends StatelessWidget {
  const _RatioLineChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final minRatio = points.map((point) => point.ratio).reduce(math.min);
    final maxRatio = points.map((point) => point.ratio).reduce(math.max);

    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _RatioLineChartPainter(
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
              '1:${minRatio.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Spacer(),
            Text(
              '1:${maxRatio.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _RatioLineChartPainter extends CustomPainter {
  const _RatioLineChartPainter({
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

    final chartRect = Rect.fromLTWH(0, 4, size.width, size.height - 24);
    final minRatio = points.map((point) => point.ratio).reduce(math.min);
    final maxRatio = points.map((point) => point.ratio).reduce(math.max);
    final spread = math.max(maxRatio - minRatio, 0.2);
    final paddedMin = minRatio - spread * 0.18;
    final paddedMax = maxRatio + spread * 0.18;
    final paddedSpread = paddedMax - paddedMin;

    final gridPaint = Paint()
      ..color = colors.border.withValues(alpha: 0.72)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = chartRect.top + chartRect.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final offsets = <Offset>[
      for (var i = 0; i < points.length; i++)
        Offset(
          points.length == 1
              ? chartRect.center.dx
              : chartRect.left + chartRect.width * (i / (points.length - 1)),
          chartRect.bottom -
              ((points[i].ratio - paddedMin) / paddedSpread) *
                  chartRect.height,
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

    _paintBottomLabel(canvas, points.first.label, offsets.first.dx, size);
    _paintBottomLabel(canvas, points.last.label, offsets.last.dx, size);
  }

  void _paintBottomLabel(
    Canvas canvas,
    String label,
    double centerX,
    Size size,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: textStyle.copyWith(fontSize: 10)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 80);

    final dx = (centerX - painter.width / 2).clamp(0, size.width - painter.width);
    painter.paint(canvas, Offset(dx.toDouble(), size.height - painter.height));
  }

  @override
  bool shouldRepaint(covariant _RatioLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.colors != colors ||
        oldDelegate.textStyle != textStyle;
  }
}

List<EspressoShot> _topRatedPool(List<EspressoShot> shots) {
  final rated = shots.where((shot) => shot.rating != null).toList()
    ..sort((a, b) {
      final rating = b.rating!.compareTo(a.rating!);
      if (rating != 0) {
        return rating;
      }
      return b.brewedAt.compareTo(a.brewedAt);
    });
  if (rated.isEmpty) {
    return [];
  }
  return rated.where((shot) => shot.rating == rated.first.rating).toList();
}

List<_TrendPoint> _ratioTrend(List<EspressoShot> shots) {
  return shots.take(8).toList().reversed.map((shot) {
    return _TrendPoint(
      label: formatShortDate(shot.brewedAt),
      ratio: shot.ratio,
    );
  }).toList();
}

String _timeRange(List<EspressoShot> shots) {
  final times = shots
      .where((shot) => shot.extractionSec != null)
      .map((shot) => shot.extractionSec!)
      .toList();
  if (times.isEmpty) {
    return '-';
  }
  final min = times.reduce((a, b) => a < b ? a : b);
  final max = times.reduce((a, b) => a > b ? a : b);
  return min == max ? '${min}s' : '$min-${max}s';
}

String _ratioRange(List<EspressoShot> shots) {
  final ratios = shots.map((shot) => shot.ratio).toList();
  final min = ratios.reduce((a, b) => a < b ? a : b);
  final max = ratios.reduce((a, b) => a > b ? a : b);
  return min == max
      ? '1 : ${min.toStringAsFixed(2)}'
      : '1 : ${min.toStringAsFixed(2)}-${max.toStringAsFixed(2)}';
}
