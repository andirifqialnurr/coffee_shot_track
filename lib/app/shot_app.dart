import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    return ShadApp.custom(
      theme: ShotTheme.shadLight(),
      darkTheme: ShotTheme.shadDark(),
      themeMode: ThemeMode.system,
      appBuilder: (context) => GetMaterialApp(
        title: 'Shot',
        debugShowCheckedModeBanner: false,
        theme: ShotTheme.light(),
        darkTheme: ShotTheme.dark(),
        themeMode: ThemeMode.system,
        initialBinding: ShotBinding(controller: _controller),
        home: const ShotShell(),
        localizationsDelegates: const [
          GlobalShadLocalizations.delegate,
        ],
        builder: (context, child) => ShadAppBuilder(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
