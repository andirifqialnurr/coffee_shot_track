import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/coffee_bean.dart';
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

      final colors = shotColors(context);
      final activeBean = store.activeOrRecentBean;
      final lastShot = store.lastShot;
      final recent = store.recentShots;

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
              const SliverToBoxAdapter(child: SectionLabel('Last Shot')),
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
                      : GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ShotDetailPage(shotId: lastShot.id!),
                            ),
                          ),
                          child: RecipeCard(
                            shot: lastShot,
                            beanName: store.beanById(lastShot.beanId)?.name,
                          ),
                        ),
                ),
              ),
              if ((lastShot?.tastingNotes ?? '').isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Text(
                      '"${lastShot!.tastingNotes}"',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: 'Brew Again',
                        icon: Icons.replay_rounded,
                        onPressed: lastShot == null
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ShotFormPage(
                                      initialShot:
                                          lastShot.duplicateForBrewAgain(),
                                    ),
                                  ),
                                ),
                      ),
                      const SizedBox(height: 10),
                      SecondaryButton(
                        label: 'New Shot',
                        icon: Icons.add_rounded,
                        onPressed: onNewShot,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SectionLabel(
                  'Recent Shots',
                  trailing: TextButton(
                    onPressed: onShowHistory,
                    child: const Text('Lihat semua'),
                  ),
                ),
              ),
              if (recent.isEmpty)
                const SliverToBoxAdapter(child: SizedBox.shrink())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: recent.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final shot = recent[index];
                      return ShotRow(
                        shot: shot,
                        beanName: store.beanById(shot.beanId)?.name ?? '-',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ShotDetailPage(shotId: shot.id!),
                          ),
                        ),
                      );
                    },
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
