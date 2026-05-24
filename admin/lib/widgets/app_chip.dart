import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

enum ChipKind { neutral, accent, success, warn, danger, lead }

/// Mono-text chip, 11-12px, used everywhere (tags, status, draft, etc.).
/// Matches `.chip.*` variants in tokens.css.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.kind = ChipKind.neutral,
    this.dense = false,
    this.leading,
    super.key,
  });

  final String label;
  final ChipKind kind;
  final bool dense;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    Color bg, fg, border;
    switch (kind) {
      case ChipKind.neutral:
        bg = t.surface2; fg = t.ink2; border = t.borderSoft;
      case ChipKind.accent:
        bg = t.accentSoft; fg = t.accentInk; border = Colors.transparent;
      case ChipKind.success:
        bg = t.successSoft; fg = t.success; border = Colors.transparent;
      case ChipKind.warn:
        bg = t.warnSoft; fg = t.warn; border = Colors.transparent;
      case ChipKind.danger:
        bg = t.dangerSoft; fg = t.dangerInk; border = Colors.transparent;
      case ChipKind.lead:
        bg = t.ink; fg = t.bg; border = t.ink;
    }
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(3),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 5)],
          Text(label, style: AppText.mono(context, size: dense ? 9.5 : 11, color: fg)),
        ],
      ),
    );
  }
}

/// "● live" / "● paused" style chip — a coloured dot + label.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, required this.kind, super.key});
  final String label;
  final ChipKind kind;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final dotColor = switch (kind) {
      ChipKind.success => t.success,
      ChipKind.warn => t.warn,
      ChipKind.danger => t.danger,
      ChipKind.accent => t.accent,
      ChipKind.lead => t.ink,
      ChipKind.neutral => t.ink3,
    };
    return AppChip(
      label: label,
      kind: kind,
      leading: Container(
        width: 6, height: 6,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
    );
  }
}
