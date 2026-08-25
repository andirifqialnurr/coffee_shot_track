import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart' as shad;

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
    final shadTheme = shad.ShadTheme.of(context);

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(color: shadTheme.colorScheme.background),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Navigator.of(context).canPop()) ...[
                          ShotIconAction(
                            tooltip: 'Back',
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 6),
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
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                    ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            shadTheme.colorScheme.mutedForeground,
                                      ),
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
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return shad.ShadCard(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
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
    final shadTheme = shad.ShadTheme.of(context);
    final colors = Theme.of(context).extension<ShotColors>()!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 84),
      child: shad.ShadCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.caramel.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colors.caramel.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(icon, size: 15, color: colors.caramel),
                  ),
                  const SizedBox(width: 8),
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
                            color: shadTheme.colorScheme.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final shadTheme = shad.ShadTheme.of(context);
    final colors = Theme.of(context).extension<ShotColors>()!;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: shadTheme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: shadTheme.colorScheme.border),
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
                        ?.copyWith(fontWeight: FontWeight.w800),
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
    final shadTheme = shad.ShadTheme.of(context);

    return ShotCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: shadTheme.colorScheme.accent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: shadTheme.colorScheme.border),
            ),
            child: Icon(icon, size: 26, color: colors.caramel),
          ),
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
                  color: shadTheme.colorScheme.mutedForeground,
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

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isActive
              ? Icons.local_fire_department_outlined
              : Icons.archive_outlined,
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(isActive ? 'Active' : 'Finished'),
      ],
    );

    if (isActive) {
      return shad.ShadBadge(
        backgroundColor: colors.success.withValues(alpha: 0.14),
        foregroundColor: colors.success,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: content,
      );
    }

    return shad.ShadBadge.outline(
      foregroundColor: colors.mutedText,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: content,
    );
  }
}

class ShotSectionHeader extends StatelessWidget {
  const ShotSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class ShotActionButton extends StatelessWidget {
  const ShotActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.width,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final leading = Icon(icon, size: 16);
    final child = Text(label);

    if (primary) {
      return shad.ShadButton(
        onPressed: onPressed,
        leading: leading,
        width: width,
        child: child,
      );
    }

    return shad.ShadButton.outline(
      onPressed: onPressed,
      leading: leading,
      width: width,
      child: child,
    );
  }
}

class ShotIconAction extends StatelessWidget {
  const ShotIconAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final shadTheme = shad.ShadTheme.of(context);

    return Tooltip(
      message: tooltip,
      child: shad.ShadButton.ghost(
        width: 40,
        height: 40,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        backgroundColor:
            selected ? shadTheme.colorScheme.secondary : Colors.transparent,
        child: Icon(icon, size: 20),
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
    final shadTheme = shad.ShadTheme.of(context);

    return shad.ShadBadge.outline(
      backgroundColor: favorite
          ? colors.caramel.withValues(alpha: 0.12)
          : shadTheme.colorScheme.secondary,
      foregroundColor:
          favorite ? colors.caramel : shadTheme.colorScheme.foreground,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
