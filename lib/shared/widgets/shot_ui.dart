import 'package:flutter/material.dart';

import '../../app/shot_theme.dart';
import '../../domain/coffee_bean.dart';
import '../../domain/espresso_shot.dart';
import '../../domain/shot_metrics.dart' as metrics;

class ShotPage extends StatelessWidget {
  const ShotPage({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.child,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverToBoxAdapter(child: child),
          ),
        ],
      ),
    );
  }
}

class ShotCard extends StatelessWidget {
  const ShotCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ShotColors>()!;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
      ),
      child: child,
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ShotColors>()!;

    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colors.caramel),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.mutedText,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              children: [
                TextSpan(text: value),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ShotColors>()!;

    return ShotCard(
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.caramel),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.mutedText,
                ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

class BeanStatusChip extends StatelessWidget {
  const BeanStatusChip({super.key, required this.status});

  final BeanStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ShotColors>()!;
    final isActive = status == BeanStatus.active;

    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(isActive ? 'Active' : 'Finished'),
      avatar: Icon(
        isActive ? Icons.local_fire_department_outlined : Icons.archive_outlined,
        size: 16,
      ),
      backgroundColor: isActive
          ? colors.success.withValues(alpha: 0.12)
          : colors.mutedText.withValues(alpha: 0.12),
      side: BorderSide.none,
    );
  }
}

class ShotListTile extends StatelessWidget {
  const ShotListTile({
    super.key,
    required this.shot,
    required this.bean,
    required this.onTap,
  });

  final EspressoShot shot;
  final CoffeeBean? bean;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ShotColors>()!;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.caramel.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                metrics.formatRatio(shot.doseG, shot.yieldG),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bean?.name ?? 'Unknown bean',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    metrics.formatShotLine(shot),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.mutedText,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _RatingPill(rating: shot.rating, favorite: shot.isFavorite),
          ],
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, required this.favorite});

  final int? rating;
  final bool favorite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ShotColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: favorite
            ? colors.caramel.withValues(alpha: 0.16)
            : colors.cardBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            favorite ? Icons.star : Icons.star_border,
            size: 16,
            color: colors.caramel,
          ),
          const SizedBox(width: 3),
          Text(rating?.toString() ?? '-'),
        ],
      ),
    );
  }
}

String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
