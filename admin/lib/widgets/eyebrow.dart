import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The "01 — section" rubric used as a top label across screens.
/// `num` is rendered dimmer so the dash + label reads as the title.
class Eyebrow extends StatelessWidget {
  const Eyebrow({required this.label, this.number, super.key});
  final String label;
  final String? number;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final style = AppText.eyebrow(context);
    return Text.rich(
      TextSpan(
        children: [
          if (number != null)
            TextSpan(text: number, style: style.copyWith(color: t.ink4)),
          if (number != null) TextSpan(text: '  —  ', style: style),
          TextSpan(text: label.toUpperCase(), style: style),
        ],
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  const SectionHead({
    required this.number,
    required this.title,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(18, 20, 18, 12),
    super.key,
  });

  final String number;
  final String title;
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(number: number, label: 'section'),
                const SizedBox(height: 4),
                Text(title, style: AppText.serif(context, size: 22)),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
