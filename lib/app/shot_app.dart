import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart' as shad;

import '../data/shot_store.dart';
import '../features/shell/shot_shell.dart';
import 'shot_binding.dart';
import 'shot_theme.dart';

class ShotApp extends StatefulWidget {
  const ShotApp({super.key, ShotController? controller})
      : _controller = controller;

  final ShotController? _controller;

  @override
  State<ShotApp> createState() => _ShotAppState();
}

class _ShotAppState extends State<ShotApp> {
  late final ShotController _controller =
      widget._controller ?? ShotController();
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ShotController>()) {
      ShotBinding(controller: _controller).dependencies();
    }
    _controller.load();
  }

  @override
  void dispose() {
    if (widget._controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shot',
      debugShowCheckedModeBanner: false,
      theme: ShotTheme.light(),
      darkTheme: ShotTheme.dark(),
      themeMode: _themeMode,
      home: ShotShell(
        themeMode: _themeMode,
        onThemeModeChanged: (value) => setState(() => _themeMode = value),
      ),
      localizationsDelegates: const [
        shad.GlobalShadLocalizations.delegate,
      ],
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return shad.ShadTheme(
          data: isDark ? ShotTheme.shadDark() : ShotTheme.shadLight(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
