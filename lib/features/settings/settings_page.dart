import 'package:flutter/material.dart';

import '../../shared/widgets/shot_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeMode _mode = widget.themeMode;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          ShotCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Dark Mode',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Text(
                'Deep charcoal + muted caramel',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _mode == ThemeMode.dark,
              activeThumbColor: colors.onPrimary,
              activeTrackColor: colors.primary,
              onChanged: (value) {
                final next = value ? ThemeMode.dark : ThemeMode.light;
                setState(() => _mode = next);
                widget.onThemeModeChanged(next);
              },
            ),
          ),
          const SectionLabel('Tentang'),
          ShotCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shot', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Coffee shot tracker lokal untuk mencatat beans, recipe, ratio, rating, dan catatan tasting.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
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
