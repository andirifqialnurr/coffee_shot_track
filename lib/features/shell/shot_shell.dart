import 'package:flutter/material.dart';

import '../../shared/widgets/shot_ui.dart';
import '../beans/beans_page.dart';
import '../cafes/cafes_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../insights/insights_page.dart';
import '../menus/menus_page.dart';
import '../orders/order_form_page.dart';
import '../settings/settings_page.dart';

class ShotShell extends StatefulWidget {
  const ShotShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShotShell> createState() => _ShotShellState();
}

class _ShotShellState extends State<ShotShell> {
  int _index = 0;

  void _goToTab(int index) {
    setState(() => _index = index);
  }

  void _openNewShot() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OrderFormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final pages = [
      HomePage(
        onNewShot: _openNewShot,
        onShowHistory: () => _goToTab(3),
        onShowMenus: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const MenusPage()),
          );
        },
        onShowCafes: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CafesPage()),
          );
        },
        onShowSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SettingsPage(
                themeMode: widget.themeMode,
                onThemeModeChanged: widget.onThemeModeChanged,
              ),
            ),
          );
        },
      ),
      const BeansPage(),
      const InsightsPage(),
      const HistoryPage(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: pages[_index],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'global-new-shot',
        onPressed: _openNewShot,
        tooltip: 'New Order',
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _ShotBottomNav(
        currentIndex: _index,
        onTap: _goToTab,
      ),
    );
  }
}

class _ShotBottomNav extends StatelessWidget {
  const _ShotBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final items = [
      (Icons.coffee_rounded, 'Home'),
      (Icons.eco_outlined, 'Beans'),
      (Icons.insights_rounded, 'Stats'),
      (Icons.history_rounded, 'History'),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              if (index == 2) const SizedBox(width: 58),
              Expanded(
                child: _ShotBottomNavItem(
                  icon: items[index].$1,
                  label: items[index].$2,
                  selected: index == currentIndex,
                  onTap: () => onTap(index),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShotBottomNavItem extends StatelessWidget {
  const _ShotBottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? colors.primary : colors.textSecondary,
                size: 23,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? colors.primary : colors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
