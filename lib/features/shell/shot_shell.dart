import 'package:flutter/material.dart';

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
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.coffee_outlined),
            selectedIcon: Icon(Icons.coffee),
            label: 'Beans',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'New Shot',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
