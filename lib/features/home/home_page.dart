import 'package:flutter/material.dart';

import '../../app/shot_scope.dart';
import '../../app/shot_theme.dart';
import '../../domain/shot_metrics.dart' as metrics;
import '../../shared/widgets/shot_ui.dart';
import '../beans/beans_page.dart';
import '../shots/shot_detail_page.dart';
import '../shots/shot_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onNewShot});

  final VoidCallback onNewShot;

  @override
  Widget build(BuildContext context) {
    final store = ShotScope.of(context);
    final colors = Theme.of(context).extension<ShotColors>()!;
    final activeBean = store.activeOrRecentBean;
    final lastShot = store.lastShot;

    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ShotPage(
      title: 'Shot',
      subtitle: 'Brew log for repeatable espresso.',
      actions: [
        IconButton(
          tooltip: 'Settings',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings are planned for V2.')),
            );
          },
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeBean == null)
            EmptyState(
              icon: Icons.coffee_maker_outlined,
              title: 'No beans yet',
              message: 'Add beans first so every shot has context.',
              action: FilledButton.icon(
                onPressed: () => showBeanFormSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Bean'),
              ),
            )
          else
            ShotCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active bean',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: colors.mutedText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeBean.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (activeBean.roaster != null) ...[
                              const SizedBox(height: 2),
                              Text(activeBean.roaster!),
                            ],
                          ],
                        ),
                      ),
                      BeanStatusChip(status: activeBean.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (lastShot == null)
                    Text(
                      'No shots logged yet.',
                      style: TextStyle(color: colors.mutedText),
                    )
                  else ...[
                    Text(
                      'Last Shot',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: colors.mutedText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metrics.formatShotLine(lastShot),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (lastShot.tastingNotes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 6),
                      Text(
                        lastShot.tastingNotes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: lastShot == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ShotFormPage(
                                        initialShot:
                                            lastShot.duplicateForBrewAgain(),
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.replay),
                          label: const Text('Brew Again'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onNewShot,
                          icon: const Icon(Icons.add),
                          label: const Text('New Shot'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _InsightGrid(
            totalShots: store.totalShots,
            averageRating: store.averageRating,
            mostUsedBean: store.mostUsedBean?.name ?? '-',
          ),
          const SizedBox(height: 20),
          Text(
            'Recent shots',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (store.recentShots.isEmpty)
            EmptyState(
              icon: Icons.history_outlined,
              title: 'No shot history',
              message: 'Your latest 3 shots will show here.',
              action: OutlinedButton.icon(
                onPressed: onNewShot,
                icon: const Icon(Icons.add),
                label: const Text('New Shot'),
              ),
            )
          else
            ShotCard(
              child: Column(
                children: [
                  for (final shot in store.recentShots)
                    ShotListTile(
                      shot: shot,
                      bean: store.beanById(shot.beanId),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ShotDetailPage(shotId: shot.id!),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightGrid extends StatelessWidget {
  const _InsightGrid({
    required this.totalShots,
    required this.averageRating,
    required this.mostUsedBean,
  });

  final int totalShots;
  final double averageRating;
  final String mostUsedBean;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 360 ? 1 : 3;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: columns == 1 ? 3.8 : 1.1,
          children: [
            MetricTile(
              label: 'Total',
              value: totalShots.toString(),
              unit: 'shots',
              icon: Icons.coffee,
            ),
            MetricTile(
              label: 'Avg rating',
              value: averageRating == 0 ? '-' : averageRating.toStringAsFixed(1),
              icon: Icons.star_outline,
            ),
            MetricTile(
              label: 'Most used',
              value: mostUsedBean,
              icon: Icons.local_cafe_outlined,
            ),
          ],
        );
      },
    );
  }
}
