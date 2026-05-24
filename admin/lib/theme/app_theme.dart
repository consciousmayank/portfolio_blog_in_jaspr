import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// One of the two design palettes. `system` follows OS dark mode.
enum AdminThemeMode { system, editorial, terminal }

extension AdminThemeModeX on AdminThemeMode {
  String get id => switch (this) {
        AdminThemeMode.system => 'system',
        AdminThemeMode.editorial => 'editorial',
        AdminThemeMode.terminal => 'terminal',
      };

  static AdminThemeMode parse(String? id) => switch (id) {
        'editorial' => AdminThemeMode.editorial,
        'terminal' => AdminThemeMode.terminal,
        _ => AdminThemeMode.system,
      };

  ThemeMode get themeMode => switch (this) {
        AdminThemeMode.system => ThemeMode.system,
        AdminThemeMode.editorial => ThemeMode.light,
        AdminThemeMode.terminal => ThemeMode.dark,
      };
}

class AppTheme {
  static ThemeData editorial() => _build(AppTokens.editorial, Brightness.light);
  static ThemeData terminal() => _build(AppTokens.terminal, Brightness.dark);

  static ThemeData _build(AppTokens t, Brightness brightness) {
    final geist = GoogleFonts.interTextTheme().apply(
      bodyColor: t.ink,
      displayColor: t.ink,
    );

    final base = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: t.bg,
      canvasColor: t.bg,
      dividerColor: t.borderSoft,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: t.ink,
        onPrimary: t.bg,
        secondary: t.accent,
        onSecondary: brightness == Brightness.light ? Colors.white : t.ink,
        error: t.danger,
        onError: Colors.white,
        surface: t.surface,
        onSurface: t.ink,
        surfaceContainerHighest: t.surface2,
        outline: t.border,
        outlineVariant: t.borderSoft,
        primaryContainer: t.accentSoft,
        onPrimaryContainer: t.accentInk,
        secondaryContainer: t.accentSoft,
        onSecondaryContainer: t.accentInk,
      ),
      textTheme: geist.copyWith(
        bodyMedium: geist.bodyMedium?.copyWith(
          fontSize: 14.5, height: 1.45, letterSpacing: -0.005 * 14.5,
        ),
        bodyLarge: geist.bodyLarge?.copyWith(
          fontSize: 14.5, height: 1.45,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        shape: Border(bottom: BorderSide(color: t.borderSoft)),
        iconTheme: IconThemeData(color: t.ink2, size: 20),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.bg2,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: t.surface3,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.jetBrainsMono(
            fontSize: 10,
            letterSpacing: 0.4,
            color: selected ? t.ink : t.ink3,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 18,
            color: selected ? t.ink : t.ink3,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: t.bg2,
        selectedIconTheme: IconThemeData(color: t.ink, size: 18),
        unselectedIconTheme: IconThemeData(color: t.ink3, size: 18),
        selectedLabelTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 11, color: t.ink, fontWeight: FontWeight.w500,
        ),
        unselectedLabelTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 11, color: t.ink3, fontWeight: FontWeight.w400,
        ),
        indicatorColor: t.surface,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: t.borderSoft),
        ),
        useIndicator: true,
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: t.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: t.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: t.accent, width: 1.5),
        ),
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 10.5,
          letterSpacing: 0.84,
          color: t.ink3,
        ),
        hintStyle: TextStyle(color: t.ink4, fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.ink,
          foregroundColor: t.bg,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.inter(
            fontSize: 13.5, fontWeight: FontWeight.w500,
            letterSpacing: -0.065,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: t.surface,
          foregroundColor: t.ink,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          side: BorderSide(color: t.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.inter(
            fontSize: 13.5, fontWeight: FontWeight.w500,
            letterSpacing: -0.065,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.ink2,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.inter(
            fontSize: 13.5, fontWeight: FontWeight.w500,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: t.ink2,
          minimumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.ink,
        foregroundColor: t.bg,
        elevation: 0,
        focusElevation: 0, hoverElevation: 0, highlightElevation: 0,
        shape: const CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surface2,
        side: BorderSide(color: t.borderSoft),
        labelStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: t.ink2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      dividerTheme: DividerThemeData(color: t.borderSoft, thickness: 1, space: 1),
      tabBarTheme: TabBarThemeData(
        labelColor: t.ink,
        unselectedLabelColor: t.ink3,
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 11.5, fontWeight: FontWeight.w500, letterSpacing: 0.92,
        ),
        unselectedLabelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 11.5, fontWeight: FontWeight.w400, letterSpacing: 0.92,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: t.ink, width: 1.5),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: t.borderSoft,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            brightness == Brightness.light ? t.bg : t.ink),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? t.accent : t.ink5),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: t.accent,
        inactiveTrackColor: t.surface3,
        thumbColor: t.accent,
        overlayColor: t.accent.withValues(alpha: 0.10),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.ink,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 13.5, color: t.bg,
        ),
        actionTextColor: t.bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.bg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: t.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.bg,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: t.bg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        showDragHandle: true,
      ),
      extensions: [t],
    );
  }
}

/// Typography helpers — design uses three families.
class AppText {
  AppText._();

  static TextStyle serif(BuildContext context, {double size = 22, bool italic = false}) =>
      GoogleFonts.instrumentSerif(
        fontSize: size,
        height: 1.1,
        letterSpacing: -size * 0.01,
        color: AppTokens.of(context).ink,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  static TextStyle mono(BuildContext context, {double size = 11, Color? color, FontWeight? weight}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        color: color ?? AppTokens.of(context).ink2,
        fontWeight: weight ?? FontWeight.w400,
      );

  static TextStyle eyebrow(BuildContext context) => GoogleFonts.jetBrainsMono(
        fontSize: 10.5,
        letterSpacing: 1.05,
        color: AppTokens.of(context).ink3,
        fontWeight: FontWeight.w400,
      );

  static TextStyle label(BuildContext context) => GoogleFonts.jetBrainsMono(
        fontSize: 10.5,
        letterSpacing: 0.84,
        color: AppTokens.of(context).ink3,
        fontWeight: FontWeight.w400,
      );
}
