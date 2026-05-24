import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth.dart';

class ShellScreen extends ConsumerWidget {
  const ShellScreen({required this.child, super.key});
  final Widget child;

  static const _items = [
    _NavItem('Blog', Icons.article_outlined, '/blog'),
    _NavItem('Timeline', Icons.timeline, '/timeline'),
    _NavItem('Skills', Icons.code, '/skills'),
    _NavItem('Experiments', Icons.science_outlined, '/experiments'),
    _NavItem('Messages', Icons.inbox_outlined, '/messages'),
    _NavItem('Settings', Icons.settings_outlined, '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final selected = _items.indexWhere((i) => location.startsWith(i.path));
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('mayankjoshi.in · admin'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      drawer: narrow ? _drawer(context, selected) : null,
      body: narrow
          ? child
          : Row(children: [
              NavigationRail(
                extended: width >= 1100,
                selectedIndex: selected >= 0 ? selected : 0,
                onDestinationSelected: (i) => context.go(_items[i].path),
                destinations: [
                  for (final i in _items)
                    NavigationRailDestination(
                      icon: Icon(i.icon),
                      label: Text(i.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ]),
    );
  }

  Drawer _drawer(BuildContext ctx, int selected) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Admin', style: TextStyle(fontSize: 20))),
          for (var i = 0; i < _items.length; i++)
            ListTile(
              leading: Icon(_items[i].icon),
              title: Text(_items[i].label),
              selected: i == selected,
              onTap: () {
                Navigator.of(ctx).pop();
                ctx.go(_items[i].path);
              },
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}
