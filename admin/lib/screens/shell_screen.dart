import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messages/last_seen.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';

/// Adaptive shell.
///   - phone (<900dp): Material 3 NavigationBar at the bottom (5 destinations).
///   - tablet/desktop (>=900dp): 220dp NavigationRail on the left.
/// Settings is reached via the avatar profile sheet, not the nav.
/// Blog editor and Login render without any of this shell.
class ShellScreen extends ConsumerWidget {
  const ShellScreen({required this.child, super.key});
  final Widget child;

  static const _items = [
    _NavItem('Blog',      Icons.article_outlined,    '/blog'),
    _NavItem('Timeline',  Icons.work_outline,        '/timeline'),
    _NavItem('Skills',    Icons.auto_awesome_outlined,'/skills'),
    _NavItem('Lab',       Icons.science_outlined,    '/experiments', sectionLabel: 'Experiments'),
    _NavItem('Messages',  Icons.inbox_outlined,      '/messages'),
  ];

  static const _railExtras = [
    _NavItem('Settings',  Icons.settings_outlined,   '/settings'),
  ];

  int _activeIndex(String location) {
    for (var i = 0; i < _items.length; i++) {
      if (location.startsWith(_items[i].path)) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final wide = MediaQuery.of(context).size.width >= 900;
    final t = AppTokens.of(context);
    final unread = ref.watch(messagesUnreadCountProvider).valueOrNull ?? 0;

    if (wide) {
      return Scaffold(
        body: Row(children: [
          _Rail(items: _items, extras: _railExtras, location: location, unread: unread),
          VerticalDivider(width: 1, color: t.borderSoft),
          Expanded(child: child),
        ]),
      );
    }

    final activeIdx = _activeIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: activeIdx < 0
          ? null
          : NavigationBar(
              selectedIndex: activeIdx,
              onDestinationSelected: (i) => context.go(_items[i].path),
              destinations: [
                for (var i = 0; i < _items.length; i++)
                  _NavDestination(
                    item: _items[i],
                    showDot: _items[i].label == 'Messages' && unread > 0,
                  ),
              ],
            ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({required this.item, required this.showDot});
  final _NavItem item;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final icon = Icon(item.icon);
    final iconWithDot = showDot
        ? Stack(clipBehavior: Clip.none, children: [
            icon,
            Positioned(
              right: -3, top: -2,
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: t.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.bg2, width: 1.5),
                ),
              ),
            ),
          ])
        : icon;
    return NavigationDestination(
      icon: iconWithDot,
      label: item.label,
    );
  }
}

class _Rail extends ConsumerWidget {
  const _Rail({
    required this.items,
    required this.extras,
    required this.location,
    required this.unread,
  });
  final List<_NavItem> items;
  final List<_NavItem> extras;
  final String location;
  final int unread;

  int _activeIndex() {
    for (var i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].path)) return i;
    }
    for (var i = 0; i < extras.length; i++) {
      if (location.startsWith(extras[i].path)) return items.length + i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppTokens.of(context);
    final activeIdx = _activeIndex();
    return Container(
      width: 220,
      color: t.bg2,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow(label: 'back room', number: '·'),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: 'mayank', style: AppText.serif(context, size: 22)),
                      TextSpan(text: 'joshi', style: AppText.serif(context, size: 22, italic: true)),
                      TextSpan(text: '.in', style: AppText.serif(context, size: 22)),
                    ]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (var i = 0; i < items.length; i++)
                    _RailRow(
                      item: items[i],
                      active: i == activeIdx,
                      showDot: items[i].label == 'Messages' && unread > 0,
                    ),
                  Divider(color: t.borderSoft, height: 24, indent: 8, endIndent: 8),
                  for (var i = 0; i < extras.length; i++)
                    _RailRow(
                      item: extras[i],
                      active: items.length + i == activeIdx,
                    ),
                ],
              ),
            ),
            Divider(color: t.borderSoft, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: t.surface3,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('MJ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mayank Joshi',
                          style: TextStyle(fontSize: 12.5, color: t.ink, height: 1)),
                      const SizedBox(height: 2),
                      Text('v 0.1.0',
                          style: AppText.mono(context, size: 10, color: t.ink4)),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailRow extends StatelessWidget {
  const _RailRow({required this.item, required this.active, this.showDot = false});
  final _NavItem item;
  final bool active;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: active ? t.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        shape: active
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: t.borderSoft),
              )
            : null,
        child: InkWell(
          onTap: () => GoRouter.of(context).go(item.path),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: [
              Icon(item.icon, size: 16, color: active ? t.ink : t.ink2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.sectionLabel ?? item.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: active ? t.ink : t.ink2,
                    fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (showDot)
                Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.path, {this.sectionLabel});
  final String label;
  final IconData icon;
  final String path;
  /// When the nav-bar label needs to be shorter than the screen title
  /// (e.g. "Lab" in the bar, "Experiments" everywhere else).
  final String? sectionLabel;
}
