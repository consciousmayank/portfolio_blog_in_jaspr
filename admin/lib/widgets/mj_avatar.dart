import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The MJ monogram chip that lives in the app bar leading slot.
/// Tap opens the profile sheet (Settings · theme · sign out).
class MJAvatar extends StatelessWidget {
  const MJAvatar({this.size = 28, this.active = false, super.key});
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: active ? t.accentSoft : t.surface3,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? t.accent : t.borderSoft,
          width: active ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'MJ',
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: active ? t.accentInk : t.ink,
          height: 1,
        ),
      ),
    );
  }
}
