import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/shot_store.dart';
import '../features/shell/shot_shell.dart';
import 'shot_binding.dart';
import 'shot_scope.dart';
import 'shot_theme.dart';

class ShotApp extends StatefulWidget {
  const ShotApp({super.key, ShotStore? store}) : _store = store;

  final ShotStore? _store;

  @override
  State<ShotApp> createState() => _ShotAppState();
}

class _ShotAppState extends State<ShotApp> {
  late final ShotStore _store = widget._store ?? ShotStore();

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    if (widget._store == null) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShotScope(
      store: _store,
      child: GetMaterialApp(
        title: 'Shot',
        theme: ShotTheme.light(),
        darkTheme: ShotTheme.dark(),
        themeMode: ThemeMode.system,
        initialBinding: ShotBinding(store: _store),
        home: const ShotShell(),
      ),
    );
  }
}
