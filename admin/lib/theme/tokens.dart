import 'package:flutter/material.dart';

/// Design tokens ported 1-to-1 from tokens.css. Two palettes (editorial /
/// terminal) — same names, swapped values. Use via `AppTokens.of(context)`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.bg,
    required this.bg2,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.border2,
    required this.borderSoft,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.ink5,
    required this.accent,
    required this.accent2,
    required this.accentSoft,
    required this.accentInk,
    required this.danger,
    required this.dangerSoft,
    required this.dangerInk,
    required this.success,
    required this.successSoft,
    required this.warn,
    required this.warnSoft,
    required this.codeBg,
    required this.codeInk,
  });

  final Color bg, bg2, surface, surface2, surface3;
  final Color border, border2, borderSoft;
  final Color ink, ink2, ink3, ink4, ink5;
  final Color accent, accent2, accentSoft, accentInk;
  final Color danger, dangerSoft, dangerInk;
  final Color success, successSoft;
  final Color warn, warnSoft;
  final Color codeBg, codeInk;

  static const editorial = AppTokens(
    bg: Color(0xFFF0EBE0),
    bg2: Color(0xFFE8E1D5),
    surface: Color(0xFFF6F2E8),
    surface2: Color(0xFFEBE4D6),
    surface3: Color(0xFFDDD4C4),
    border: Color(0xFFD4CCBA),
    border2: Color(0xFFC4BAA4),
    borderSoft: Color(0xFFE0D8C8),
    ink: Color(0xFF1F1C17),
    ink2: Color(0xFF3F3A30),
    ink3: Color(0xFF756E60),
    ink4: Color(0xFFA89F8C),
    ink5: Color(0xFFC4BBA8),
    accent: Color(0xFF8A5A8C),
    accent2: Color(0xFF6A4670),
    accentSoft: Color(0xFFEAD8EB),
    accentInk: Color(0xFF4A2C50),
    danger: Color(0xFFA64545),
    dangerSoft: Color(0xFFF0DADA),
    dangerInk: Color(0xFF6C2A2A),
    success: Color(0xFF3F6B3F),
    successSoft: Color(0xFFD8E6D4),
    warn: Color(0xFFA87328),
    warnSoft: Color(0xFFEFE1C5),
    codeBg: Color(0xFF2A2620),
    codeInk: Color(0xFFDDD0B8),
  );

  static const terminal = AppTokens(
    bg: Color(0xFF14192C),
    bg2: Color(0xFF18203A),
    surface: Color(0xFF1C2440),
    surface2: Color(0xFF232C4C),
    surface3: Color(0xFF2C3658),
    border: Color(0xFF2A345A),
    border2: Color(0xFF3A4670),
    borderSoft: Color(0xFF1F2848),
    ink: Color(0xFFECF0F8),
    ink2: Color(0xFFC4CCE0),
    ink3: Color(0xFF8892AC),
    ink4: Color(0xFF5A6480),
    ink5: Color(0xFF3E4768),
    accent: Color(0xFF6BA3D6),
    accent2: Color(0xFF9BC3E6),
    accentSoft: Color(0xFF1F3A5E),
    accentInk: Color(0xFFB5D3ED),
    danger: Color(0xFFD67878),
    dangerSoft: Color(0xFF3A2030),
    dangerInk: Color(0xFFE8A4A4),
    success: Color(0xFF7BC97B),
    successSoft: Color(0xFF1F3A2A),
    warn: Color(0xFFD4A85C),
    warnSoft: Color(0xFF3A2C14),
    codeBg: Color(0xFF0D1120),
    codeInk: Color(0xFFB5C4DC),
  );

  static AppTokens of(BuildContext context) =>
      Theme.of(context).extension<AppTokens>() ?? editorial;

  @override
  AppTokens copyWith({
    Color? bg, Color? bg2, Color? surface, Color? surface2, Color? surface3,
    Color? border, Color? border2, Color? borderSoft,
    Color? ink, Color? ink2, Color? ink3, Color? ink4, Color? ink5,
    Color? accent, Color? accent2, Color? accentSoft, Color? accentInk,
    Color? danger, Color? dangerSoft, Color? dangerInk,
    Color? success, Color? successSoft,
    Color? warn, Color? warnSoft,
    Color? codeBg, Color? codeInk,
  }) =>
      AppTokens(
        bg: bg ?? this.bg, bg2: bg2 ?? this.bg2,
        surface: surface ?? this.surface,
        surface2: surface2 ?? this.surface2,
        surface3: surface3 ?? this.surface3,
        border: border ?? this.border, border2: border2 ?? this.border2,
        borderSoft: borderSoft ?? this.borderSoft,
        ink: ink ?? this.ink, ink2: ink2 ?? this.ink2,
        ink3: ink3 ?? this.ink3, ink4: ink4 ?? this.ink4,
        ink5: ink5 ?? this.ink5,
        accent: accent ?? this.accent, accent2: accent2 ?? this.accent2,
        accentSoft: accentSoft ?? this.accentSoft,
        accentInk: accentInk ?? this.accentInk,
        danger: danger ?? this.danger,
        dangerSoft: dangerSoft ?? this.dangerSoft,
        dangerInk: dangerInk ?? this.dangerInk,
        success: success ?? this.success,
        successSoft: successSoft ?? this.successSoft,
        warn: warn ?? this.warn, warnSoft: warnSoft ?? this.warnSoft,
        codeBg: codeBg ?? this.codeBg, codeInk: codeInk ?? this.codeInk,
      );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      bg: l(bg, other.bg), bg2: l(bg2, other.bg2),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      border: l(border, other.border), border2: l(border2, other.border2),
      borderSoft: l(borderSoft, other.borderSoft),
      ink: l(ink, other.ink), ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3), ink4: l(ink4, other.ink4),
      ink5: l(ink5, other.ink5),
      accent: l(accent, other.accent), accent2: l(accent2, other.accent2),
      accentSoft: l(accentSoft, other.accentSoft),
      accentInk: l(accentInk, other.accentInk),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      dangerInk: l(dangerInk, other.dangerInk),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      warn: l(warn, other.warn), warnSoft: l(warnSoft, other.warnSoft),
      codeBg: l(codeBg, other.codeBg), codeInk: l(codeInk, other.codeInk),
    );
  }
}
