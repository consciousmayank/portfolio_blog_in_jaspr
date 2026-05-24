import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'eyebrow.dart';
import 'mj_avatar.dart';

/// Shared app bar matching the design — leading slot is either back arrow
/// (editor / detail screens) or the MJ avatar (nav screens). The title
/// uses Instrument Serif and is preceded by an "01 — section" eyebrow.
class DesignAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DesignAppBar({
    required this.title,
    this.eyebrow,
    this.eyebrowNumber,
    this.leading,
    this.actions,
    this.onAvatarTap,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? eyebrowNumber;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onAvatarTap;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final lead = leading ??
        IconButton(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          onPressed: onAvatarTap,
          icon: const MJAvatar(),
        );
    return AppBar(
      leading: lead,
      leadingWidth: 48,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (eyebrow != null) ...[
            Eyebrow(number: eyebrowNumber, label: eyebrow!),
            const SizedBox(height: 2),
          ],
          Text(
            title,
            style: AppText.serif(context, size: 21).copyWith(color: t.ink),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: actions,
    );
  }
}
