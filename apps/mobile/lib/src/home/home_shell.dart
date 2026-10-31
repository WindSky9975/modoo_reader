import 'package:flutter/material.dart';
import 'package:modoo_l10n/modoo_l10n.dart';

import '../features/bookshelf/bookshelf_page.dart';
import '../features/settings/settings_page.dart';

/// Two tabs for M0; the reader route arrives in M1.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: const <Widget>[BookshelfPage(), SettingsPage()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon: const Icon(Icons.auto_stories),
            label: context.l10n.bookshelfTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.settingsTitle,
          ),
        ],
      ),
    );
  }
}
