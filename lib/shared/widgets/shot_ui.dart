import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/shot_theme.dart';
import '../../domain/coffee_bean.dart';
import '../../domain/espresso_shot.dart';
import '../../domain/shot_metrics.dart' as metrics;

ShotColors shotColors(BuildContext context) {
  return Theme.of(context).extension<ShotColors>() ?? ShotTheme.lightColors;
}

class ShotPageFrame extends StatelessWidget {
  const ShotPageFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 100),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}

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
    final colors = shotColors(context);
    return ShotPageFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Navigator.of(context).canPop()) ...[
                ShotIconAction(
                  tooltip: 'Back',
                  icon: Icons.arrow_back_rounded,
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
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              ...actions,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing, this.fontSize});

  final String text;
  final Widget? trailing;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class ShotCard extends StatelessWidget {
  const ShotCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.surfaceAlt = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool surfaceAlt;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceAlt ? colors.surfaceAlt : colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }
}

class ShotImagePlaceholder extends StatelessWidget {
  const ShotImagePlaceholder({
    super.key,
    required this.label,
    required this.icon,
    this.height = 72,
    this.width = double.infinity,
    this.radius = 14,
  });

  final String label;
  final IconData icon;
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceAlt,
                colors.accent.withValues(alpha: 0.22),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _PlaceholderPatternPainter(colors.border),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: colors.primary, size: 24),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPatternPainter extends CustomPainter {
  const _PlaceholderPatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width; x += 18) {
      canvas.drawLine(
        Offset(x.toDouble(), size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlaceholderPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
  });

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: filled
              ? colors.accent
              : colors.textSecondary.withValues(alpha: 0.5),
        );
      }),
    );
  }
}

class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        final filled = value <= rating;
        return IconButton(
          tooltip: '$value stars',
          onPressed: () => onChanged(value == rating ? 0 : value),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled
                ? colors.accent
                : colors.textSecondary.withValues(alpha: 0.5),
            size: 30,
          ),
        );
      }),
    );
  }
}

class UnitChip extends StatelessWidget {
  const UnitChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class BeanStatusChip extends StatelessWidget {
  const BeanStatusChip({super.key, required this.status});

  final BeanStatus status;

  @override
  Widget build(BuildContext context) => StatusPill(status);
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});

  final BeanStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final active = status == BeanStatus.active;
    final color = active ? colors.success : colors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Finished',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.shot,
    this.beanName,
    this.compact = false,
  });

  final EspressoShot shot;
  final String? beanName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (beanName != null) ...[
            Row(
              children: [
                Icon(Icons.eco_outlined, size: 14, color: colors.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    beanName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (shot.rating != null)
                  StarRating(rating: shot.rating!, size: 14),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              HeroNumber(
                value: formatNumber(shot.doseG, fixed: true),
                unit: 'g',
                label: 'Dose',
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 6, right: 6),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ),
              HeroNumber(
                value: formatNumber(shot.yieldG, fixed: true),
                unit: 'g',
                label: 'Yield',
              ),
              const Spacer(),
              if (shot.extractionSec != null)
                HeroNumber(
                  value: '${shot.extractionSec}',
                  unit: 's',
                  label: 'Time',
                  alignEnd: true,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              formatSpacedRatio(shot.doseG, shot.yieldG),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: compact ? 20 : 26,
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((shot.grindSetting ?? '').isNotEmpty)
                  UnitChip('Grind ${shot.grindSetting}'),
                if (shot.temperatureC != null)
                  UnitChip('${formatNumber(shot.temperatureC!)} C'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class HeroNumber extends StatelessWidget {
  const HeroNumber({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.alignEnd = false,
  });

  final String value;
  final String unit;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 30,
                      height: 1,
                      color: colors.textPrimary,
                    ),
              ),
              TextSpan(
                text: unit,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    String? message,
    String? subtitle,
    this.action,
    this.ctaLabel,
    this.onCta,
  }) : subtitle = subtitle ?? message ?? '';

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
          if (action != null || ctaLabel != null) ...[
            const SizedBox(height: 18),
            action ??
                PrimaryButton(
                  label: ctaLabel!,
                  onPressed: onCta,
                ),
          ],
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.width = double.infinity,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        child: _ButtonContent(label: label, icon: icon),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.width = double.infinity,
    this.danger = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return SizedBox(
      width: width,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: danger
            ? OutlinedButton.styleFrom(
                foregroundColor: colors.danger,
                side: BorderSide(color: colors.danger.withValues(alpha: 0.45)),
              )
            : null,
        child: _ButtonContent(label: label, icon: icon),
      ),
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
    this.width = double.infinity,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return PrimaryButton(
        label: label,
        icon: icon,
        onPressed: onPressed,
        width: width,
      );
    }
    return SecondaryButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      width: width,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 19),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class ShotFilterPill extends StatelessWidget {
  const ShotFilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterPill(
      label: label,
      selected: selected,
      onTap: onPressed,
      icon: icon,
    );
  }
}

class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? colors.onPrimary : colors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color:
                          selected ? colors.onPrimary : colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
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
    final colors = shotColors(context);
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: selected ? colors.accent : colors.textPrimary,
        style: IconButton.styleFrom(
          backgroundColor: selected ? colors.surfaceAlt : Colors.transparent,
          minimumSize: const Size(44, 44),
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
    return ShotRow(
      shot: shot,
      beanName: bean?.name ?? 'Unknown bean',
      onTap: onTap,
    );
  }
}

class ShotRow extends StatelessWidget {
  const ShotRow({
    super.key,
    required this.shot,
    required this.beanName,
    required this.onTap,
    this.showBeanName = true,
  });

  final EspressoShot shot;
  final String beanName;
  final VoidCallback onTap;
  final bool showBeanName;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBeanName) ...[
                    Text(
                      beanName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    '${formatNumber(shot.doseG, fixed: true)}g -> '
                    '${formatNumber(shot.yieldG, fixed: true)}g'
                    '${shot.extractionSec == null ? '' : ' * ${shot.extractionSec}s'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatDateTime(shot.brewedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatSpacedRatio(shot.doseG, shot.yieldG),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                if (shot.rating != null)
                  StarRating(rating: shot.rating!, size: 12)
                else if (shot.isFavorite)
                  Icon(Icons.star_rounded, size: 16, color: colors.accent),
              ],
            ),
          ],
        ),
      ),
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
    return StatCard(
      label: label,
      value: unit == null ? value : '$value $unit',
      icon: icon ?? Icons.query_stats_rounded,
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.sub,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.accent, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.textSecondary,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          minLines: minLines,
          maxLines: maxLines,
          textInputAction: textInputAction,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class ParamGrid extends StatelessWidget {
  const ParamGrid({super.key, required this.children, required this.compact});

  final List<Widget> children;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: compact ? 1.5 : 1.7,
      children: children,
    );
  }
}

class NumberParamField extends StatelessWidget {
  const NumberParamField({
    super.key,
    required this.label,
    required this.unit,
    required this.controller,
    required this.icon,
    this.isInt = false,
    this.optional = false,
    this.onChanged,
    this.onEditingComplete,
    this.error,
  });

  final String label;
  final String unit;
  final TextEditingController controller;
  final IconData icon;
  final bool isInt;
  final bool optional;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final hasError = error != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? colors.danger : colors.border,
          width: hasError ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colors.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label + (optional ? ' (optional)' : ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey<String>('param-$label'),
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: !isInt,
                  ),
                  inputFormatters: [
                    if (isInt)
                      FilteringTextInputFormatter.digitsOnly
                    else
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: onChanged,
                  onEditingComplete: onEditingComplete,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 22,
                      ),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: '0',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 2),
                child: Text(
                  unit,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                error!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.danger,
                      fontSize: 10.5,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class TextParamField extends StatelessWidget {
  const TextParamField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colors.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
          const Spacer(),
          TextField(
            key: ValueKey<String>('param-$label'),
            controller: controller,
            style: Theme.of(context).textTheme.titleSmall,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

String formatNumber(double value, {bool fixed = false}) {
  if (fixed) {
    return value.toStringAsFixed(1);
  }
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

String formatSpacedRatio(double doseG, double yieldG) {
  if (doseG <= 0) {
    return '1 : -';
  }
  return '1 : ${(yieldG / doseG).toStringAsFixed(2)}';
}

String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatHumanDate(DateTime? date) {
  if (date == null) {
    return '-';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatDateTime(DateTime date) {
  return '${formatHumanDate(date)} * ${formatTime(date)}';
}

String formatShotLine(EspressoShot shot) => metrics.formatShotLine(shot);
