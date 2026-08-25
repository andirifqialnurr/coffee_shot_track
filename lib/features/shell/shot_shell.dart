import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart' as shad;

import '../../app/shot_theme.dart';
import '../beans/beans_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../shots/shot_form_page.dart';

class ShotShell extends StatefulWidget {
  const ShotShell({super.key});

  @override
  State<ShotShell> createState() => _ShotShellState();
}

class _ShotShellState extends State<ShotShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNewShot: () => setState(() => _index = 2)),
      const BeansPage(),
      const ShotFormPage(),
      const HistoryPage(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: pages[_index]),
          _ShotNavBar(
            selectedIndex: _index,
            onSelected: (value) => setState(() => _index = value),
            items: const [
              _ShotNavItemData(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              _ShotNavItemData(
                icon: Icons.coffee_outlined,
                selectedIcon: Icons.coffee,
                label: 'Beans',
              ),
              _ShotNavItemData(
                icon: Icons.add_circle_outline,
                selectedIcon: Icons.add_circle,
                label: 'New Shot',
              ),
              _ShotNavItemData(
                icon: Icons.history_outlined,
                selectedIcon: Icons.history,
                label: 'History',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShotNavBar extends StatelessWidget {
  const _ShotNavBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<_ShotNavItemData> items;

  @override
  Widget build(BuildContext context) {
    final shadTheme = shad.ShadTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: shadTheme.colorScheme.background,
        border: Border(top: BorderSide(color: shadTheme.colorScheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: shad.ShadCard(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    for (var index = 0; index < items.length; index++)
                      Expanded(
                        child: _ShotNavItem(
                          data: items[index],
                          selected: selectedIndex == index,
                          onTap: () => onSelected(index),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShotNavItem extends StatelessWidget {
  const _ShotNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _ShotNavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shadTheme = shad.ShadTheme.of(context);
    final colors = Theme.of(context).extension<ShotColors>()!;
    final foreground = selected
        ? shadTheme.colorScheme.primaryForeground
        : shadTheme.colorScheme.mutedForeground;

    return Tooltip(
      message: data.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? shadTheme.colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? colors.caramel.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? data.selectedIcon : data.icon,
                size: 20,
                color: foreground,
              ),
              const SizedBox(height: 3),
              Flexible(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShotNavItemData {
  const _ShotNavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
