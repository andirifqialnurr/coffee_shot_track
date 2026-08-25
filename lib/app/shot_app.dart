import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/shot_store.dart';
import '../features/shell/shot_shell.dart';
import 'shot_binding.dart';
import 'shot_scope.dart';
import 'shot_theme.dart';

class ShotApp extends StatefulWidget {
  const ShotApp({super.key, ShotController? controller, ShotStore? store})
      : _controller = controller ?? store;

  final ShotController? _controller;

  @override
  State<ShotApp> createState() => _ShotAppState();
}

class _ShotAppState extends State<ShotApp> {
  late final ShotController _controller =
      widget._controller ?? ShotController();

  @override
  void initState() {
    super.initState();
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
    return ShotScope(
      store: _controller,
      child: GetMaterialApp(
        title: 'Shot',
        theme: ShotTheme.light(),
        darkTheme: ShotTheme.dark(),
        themeMode: ThemeMode.system,
        initialBinding: ShotBinding(controller: _controller),
        home: const ShotShell(),
      ),
    );
  }
}
