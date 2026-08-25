import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(title: const Text('Simple Insights')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
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
            const SizedBox(height: 10),
            StatCard(
              label: 'Most-used Bean',
              value: mostUsedBean?.name ?? '-',
              icon: Icons.eco_outlined,
              sub: mostUsedBean == null ? null : '$mostUsedCount shots dicatat',
            ),
            const SectionLabel('Highlight untuk Active Bean'),
            if (activeBean == null || highlightPool.isEmpty)
              ShotCard(
                surfaceAlt: true,
                child: Text(
                  'Data belum cukup untuk menampilkan highlight rentang time/ratio.',
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
                            '${activeBean.name} * shot ber-rating tertinggi',
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
                    const SizedBox(height: 10),
                    Text(
                      'Perhitungan lokal sederhana berdasarkan data Anda sendiri.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
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
