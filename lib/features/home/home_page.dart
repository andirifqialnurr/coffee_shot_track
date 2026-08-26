import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/espresso_shot.dart';
import '../../shared/widgets/shot_ui.dart';
import '../shots/shot_detail_page.dart';
import '../shots/shot_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onNewShot,
    required this.onShowHistory,
    required this.onShowBeans,
    required this.onShowInsights,
    required this.onShowSettings,
  });

  final VoidCallback onNewShot;
  final VoidCallback onShowHistory;
  final VoidCallback onShowBeans;
  final VoidCallback onShowInsights;
  final VoidCallback onShowSettings;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      if (store.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final lastShots = store.recentShots.take(2).toList();

      return ShotPageFrame(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greetingLabel(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Shot',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ShotIconAction(
                          tooltip: 'Insights',
                          icon: Icons.insights_rounded,
                          onPressed: onShowInsights,
                        ),
                        ShotIconAction(
                          tooltip: 'Settings',
                          icon: Icons.settings_outlined,
                          onPressed: onShowSettings,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (store.beans.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.eco_outlined,
                  title: 'Belum ada beans',
                  subtitle: 'Tambahkan beans pertama Anda untuk mulai mencatat.',
                  ctaLabel: 'Add Beans',
                  onCta: onShowBeans,
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionLabel(
                    'Last Orders',
                    fontSize: 14,
                    trailing: TextButton(
                      onPressed: onShowHistory,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 28),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      child: const Text('See all'),
                    ),
                  ),
                ),
              ),
              if (lastShots.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: EmptyState(
                      icon: Icons.local_cafe_outlined,
                      title: 'Belum ada order',
                      subtitle: 'Catat order pertama Anda.',
                      ctaLabel: 'New Order',
                      onCta: onNewShot,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 188,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: lastShots.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final shot = lastShots[index];
                        return SizedBox(
                          width: 272,
                          child: _HomeShotCard(
                            shot: shot,
                            beanName: store.beanById(shot.beanId)?.name,
                            onBrewAgain: index == 0
                                ? () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ShotFormPage(
                                          initialShot:
                                              shot.duplicateForBrewAgain(),
                                        ),
                                      ),
                                    )
                                : null,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ShotDetailPage(shotId: shot.id!),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      );
    });
  }
}

class _HomeShotCard extends StatelessWidget {
  const _HomeShotCard({
    required this.shot,
    required this.onTap,
    this.beanName,
    this.onBrewAgain,
  });

  final EspressoShot shot;
  final String? beanName;
  final VoidCallback onTap;
  final VoidCallback? onBrewAgain;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final notes = shot.tastingNotes?.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco_outlined, size: 14, color: colors.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    beanName ?? 'Unknown bean',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ),
                if (shot.rating != null)
                  StarRating(rating: shot.rating!, size: 13),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ShotValue(
                  label: 'Dose',
                  value: '${formatNumber(shot.doseG, fixed: true)}g',
                ),
                const SizedBox(width: 12),
                _ShotValue(
                  label: 'Yield',
                  value: '${formatNumber(shot.yieldG, fixed: true)}g',
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formatSpacedRatio(shot.doseG, shot.yieldG),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 13,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  shot.extractionSec == null ? '-' : '${shot.extractionSec}s',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatHumanDate(shot.brewedAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (onBrewAgain != null)
                  TextButton.icon(
                    onPressed: onBrewAgain,
                    icon: const Icon(Icons.replay_rounded, size: 14),
                    label: const Text('Brew Again'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
              ],
            ),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShotValue extends StatelessWidget {
  const _ShotValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}

String greetingLabel() {
  final hour = DateTime.now().hour;
  if (hour < 11) {
    return 'Selamat pagi';
  }
  if (hour < 15) {
    return 'Selamat siang';
  }
  if (hour < 18) {
    return 'Selamat sore';
  }
  return 'Selamat malam';
}
