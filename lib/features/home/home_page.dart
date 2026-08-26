import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/coffee_bean.dart';
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

      final activeBean = store.activeOrRecentBean;
      final lastShot = store.lastShot;
      final recent = store.recentShots
          .skip(lastShot == null ? 0 : 1)
          .take(2)
          .toList();

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
            if (activeBean == null)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.eco_outlined,
                  title: 'Belum ada beans',
                  subtitle:
                      'Tambahkan beans pertama Anda untuk mulai mencatat shot.',
                  ctaLabel: 'Add Beans',
                  onCta: onShowBeans,
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _ActiveBeanCard(bean: activeBean),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SectionLabel('Last Shot', fontSize: 14),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: lastShot == null
                      ? EmptyState(
                          icon: Icons.local_cafe_outlined,
                          title: 'Belum ada shot',
                          subtitle:
                              'Catat shot pertama Anda untuk beans ini.',
                          ctaLabel: 'New Shot',
                          onCta: onNewShot,
                        )
                      : _HomeShotCard(
                          shot: lastShot,
                          beanName: store.beanById(lastShot.beanId)?.name,
                          onBrewAgain: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ShotFormPage(
                                initialShot: lastShot.duplicateForBrewAgain(),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ShotDetailPage(shotId: lastShot.id!),
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionLabel(
                    'Recent Shots',
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
              if (recent.isEmpty)
                const SliverToBoxAdapter(child: SizedBox.shrink())
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 188,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: recent.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final shot = recent[index];
                        return SizedBox(
                          width: 272,
                          child: _HomeShotCard(
                            shot: shot,
                            beanName: store.beanById(shot.beanId)?.name,
                            compact: true,
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
    this.compact = false,
  });

  final EspressoShot shot;
  final String? beanName;
  final VoidCallback onTap;
  final VoidCallback? onBrewAgain;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final notes = shot.tastingNotes?.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 14 : 16),
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
                  StarRating(rating: shot.rating!, size: compact ? 12 : 13),
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
                          fontSize: compact ? 12 : 13,
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
            if (!compact && notes != null && notes.isNotEmpty) ...[
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

class _ActiveBeanCard extends StatelessWidget {
  const _ActiveBeanCard({required this.bean});

  final CoffeeBean bean;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.eco_rounded, color: colors.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sedang diseduh',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  bean.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (bean.roaster != null)
                  Text(
                    bean.roaster!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.8),
                        ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.onPrimary.withValues(alpha: 0.8),
          ),
        ],
      ),
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
