import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';
import '../widgets/mj_avatar.dart';

/// Bottom sheet shown when the MJ avatar in the app bar is tapped.
/// Contains: identity card, theme segmented control, Settings, Open public
/// site, Sign out. Matches phone-screens.jsx ScreenShell popover layout.
Future<void> showProfileSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _ProfileSheet(),
  );
}

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppTokens.of(context);
    final mode = ref.watch(themeControllerProvider);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Identity row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Row(
                children: [
                  const MJAvatar(size: 40, active: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mayank Joshi',
                            style: AppText.serif(context, size: 18)),
                        const SizedBox(height: 4),
                        Text('admin · mayankjoshi.in',
                            style: AppText.mono(context, size: 10.5, color: t.ink3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: t.borderSoft, height: 1),
            // Theme segmented control
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Eyebrow(label: 'theme'),
                  ),
                  const SizedBox(height: 8),
                  _ThemeToggleRow(active: mode),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SheetItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/settings');
              },
            ),
            _SheetItem(
              icon: Icons.open_in_new,
              label: 'Open public site',
              trailing: Text('↗',
                  style: AppText.mono(context, size: 11, color: t.ink4)),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Open https://mayankjoshi.in in your browser.',
                  ),
                ));
              },
            ),
            _SheetItem(
              icon: Icons.logout,
              label: 'Sign out',
              danger: true,
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggleRow extends ConsumerWidget {
  const _ThemeToggleRow({required this.active});
  final AdminThemeMode active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppTokens.of(context);
    Widget pill(String label, AdminThemeMode m) {
      final on = active == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => ref.read(themeControllerProvider.notifier).setMode(m),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: on ? t.bg : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: on ? t.borderSoft : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              label.toUpperCase(),
              style: AppText.mono(
                context, size: 10.5,
                color: on ? t.ink : t.ink3,
              ).copyWith(letterSpacing: 0.84),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(children: [
        pill('System', AdminThemeMode.system),
        const SizedBox(width: 4),
        pill('Editorial', AdminThemeMode.editorial),
        const SizedBox(width: 4),
        pill('Terminal', AdminThemeMode.terminal),
      ]),
    );
  }
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.danger = false,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Icon(icon, size: 16, color: danger ? t.danger : t.ink2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: danger ? t.danger : t.ink2,
                  )),
            ),
            if (trailing != null) trailing!,
          ]),
        ),
      ),
    );
  }
}
