import 'package:flutter/material.dart';

import '../data/shot_store.dart';
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
      child: MaterialApp(
        title: 'Shot',
        theme: ShotTheme.light(),
        darkTheme: ShotTheme.dark(),
        themeMode: ThemeMode.system,
        home: const ShotBootstrapPage(),
      ),
    );
  }
}

class ShotBootstrapPage extends StatelessWidget {
  const ShotBootstrapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ShotScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: store.isLoading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Shot',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coffee Shot Tracker is ready.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
