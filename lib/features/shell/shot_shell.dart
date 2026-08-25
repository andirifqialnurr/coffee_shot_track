import 'package:flutter/material.dart';

import '../../shared/widgets/shot_ui.dart';
import '../beans/beans_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../insights/insights_page.dart';
import '../settings/settings_page.dart';
import '../shots/shot_form_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onNewShot: () => _goToTab(2),
        onShowHistory: () => _goToTab(3),
        onShowBeans: () => _goToTab(1),
        onShowInsights: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const InsightsPage()),
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
      const ShotFormPage(),
      const HistoryPage(),
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: pages[_index],
      ),
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
      (Icons.add_circle_outline_rounded, 'New Shot'),
      (Icons.history_rounded, 'History'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final selected = index == currentIndex;
            final (icon, label) = items[index];
            return Expanded(
              child: Tooltip(
                message: label,
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          color: selected
                              ? colors.primary
                              : colors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: selected
                                        ? colors.primary
                                        : colors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
