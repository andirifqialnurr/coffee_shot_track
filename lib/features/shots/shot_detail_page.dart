import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/shot_theme.dart';
import '../../data/shot_store.dart';
import '../../domain/shot_metrics.dart' as metrics;
import '../../shared/widgets/shot_ui.dart';
import 'shot_form_page.dart';

class ShotDetailPage extends StatelessWidget {
  const ShotDetailPage({super.key, required this.shotId});

  final int shotId;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();
    final colors = Theme.of(context).extension<ShotColors>()!;

    return Obx(() {
      final shot = store.shots.where((item) => item.id == shotId).firstOrNull;
      if (shot == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Shot')),
          body: const Center(child: Text('Shot not found.')),
        );
      }
      final bean = store.beanById(shot.beanId);

      return Scaffold(
        appBar: AppBar(
          title: Text(bean?.name ?? 'Shot detail'),
          actions: [
            IconButton(
              tooltip: shot.isFavorite ? 'Remove Favorite' : 'Set Favorite',
              onPressed: () => store.toggleFavorite(shot),
              icon: Icon(shot.isFavorite ? Icons.star : Icons.star_border),
            ),
            IconButton(
              tooltip: 'Edit Shot',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ShotFormPage(initialShot: shot),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ShotCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipe',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colors.mutedText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metrics.formatRatio(shot.doseG, shot.yieldG),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth < 360 ? 2 : 3;
                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.18,
                          children: [
                            MetricTile(
                              label: 'Dose',
                              value: _formatNumber(shot.doseG),
                              unit: 'g',
                              icon: Icons.scale_outlined,
                            ),
                            MetricTile(
                              label: 'Yield',
                              value: _formatNumber(shot.yieldG),
                              unit: 'g',
                              icon: Icons.water_drop_outlined,
                            ),
                            MetricTile(
                              label: 'Time',
                              value: shot.extractionSec?.toString() ?? '-',
                              unit: 'sec',
                              icon: Icons.timer_outlined,
                            ),
                            MetricTile(
                              label: 'Temp',
                              value: shot.temperatureC == null
                                  ? '-'
                                  : _formatNumber(shot.temperatureC!),
                              unit: 'C',
                              icon: Icons.thermostat_outlined,
                            ),
                            MetricTile(
                              label: 'Rating',
                              value: shot.rating?.toString() ?? '-',
                              icon: Icons.star_outline,
                            ),
                            MetricTile(
                              label: 'Grind',
                              value: shot.grindSetting ?? '-',
                              icon: Icons.tune,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ShotCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(shot.tastingNotes ?? 'No tasting notes.'),
                    const SizedBox(height: 12),
                    Text(
                      'Brewed ${formatShortDate(shot.brewedAt)}',
                      style: TextStyle(color: colors.mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ShotFormPage(
                        initialShot: shot.duplicateForBrewAgain(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.replay),
                label: const Text('Brew Again'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Shot'),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final store = Get.find<ShotController>();
    final shot = store.shots.where((item) => item.id == shotId).firstOrNull;
    if (shot == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete shot?'),
        content: const Text('This removes only this shot record.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.deleteShot(shot);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

String _formatNumber(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}
