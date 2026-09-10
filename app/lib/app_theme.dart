import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RADIAN App Themes
// Sikhay and Valiger Collaboration
// Two themes: Obsidian (dark, default), Vernier (light)
// ─────────────────────────────────────────────────────────────────────────────

// ── Color Palettes ───────────────────────────────────────────────────────────

class VernierColors {
  static const bg         = Color(0xFFF0EFE9);
  static const white      = Color(0xFFFCFCFB);
  static const card       = Color(0xFFFBF9F3);
  static const ink        = Color(0xFF212B3B);
  static const inkSoft    = Color(0xFF69707D);
  static const inkFaint   = Color(0xFF9AA0AA);
  static const navy       = Color(0xFF1C3A5E);
  static const navySoft   = Color(0xFF5A7291);
  static const line       = Color(0x171C3A5E); // rgba(28,58,94,0.09)
  static const lineStrong = Color(0x331C3A5E); // rgba(28,58,94,0.20)
  static const hair       = Color(0x591C3A5E); // rgba(28,58,94,0.35)
  static const coral      = Color(0xFFC06A4C);
  static const coralWash  = Color(0x23C06A4C); // rgba(192,106,76,0.14)
  static const teal       = Color(0xFF4B7D6E);
  static const tealWash   = Color(0x234B7D6E); // rgba(75,125,110,0.14)
  static const amber      = Color(0xFFB3873C);
  static const amberWash  = Color(0x29B3873C); // rgba(179,135,60,0.16)
}

class ObsidianColors {
  static const background   = Color(0xFF0D1117);
  static const surface      = Color(0xFF161B22);
  static const border       = Color(0xFF30363D);
  static const primary      = Color(0xFF58A6FF);
  static const secondary    = Color(0xFF3DCFB8);
  static const arm1         = Color(0xFFF78166);
  static const arm2         = Color(0xFF7EE787);
  static const resultant    = Color(0xFFE3B341);
  static const textPrimary  = Color(0xFFE6EDF3);
  static const textMuted    = Color(0xFF8B949E);
  static const positive     = Color(0xFF58A6FF);
  static const negative     = Color(0xFFF78166);
  static const error        = Color(0xFFF85149);
}

// ── UI Theme Extension ────────────────────────────────────────────────────────
// Semantic surface/text/accent tokens — mirrors the CSS custom-property tokens
// consumed by components/ui/*.tsx on the website (website/app/globals.css),
// so screens read `theme.extension<RadianUiTheme>()!.X` instead of hardcoding
// a specific palette (VernierColors/ObsidianColors) and losing theme-awareness.

class RadianUiTheme extends ThemeExtension<RadianUiTheme> {
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textFaint;
  final Color divider;
  final Color border;
  final Color success;
  final Color warning;
  final Color accentSoft;

  const RadianUiTheme({
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textFaint,
    required this.divider,
    required this.border,
    required this.success,
    required this.warning,
    required this.accentSoft,
  });

  @override
  RadianUiTheme copyWith({
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textFaint,
    Color? divider,
    Color? border,
    Color? success,
    Color? warning,
    Color? accentSoft,
  }) {
    return RadianUiTheme(
      surface:       surface       ?? this.surface,
      textPrimary:   textPrimary   ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textFaint:     textFaint     ?? this.textFaint,
      divider:       divider       ?? this.divider,
      border:        border        ?? this.border,
      success:       success       ?? this.success,
      warning:       warning       ?? this.warning,
      accentSoft:    accentSoft    ?? this.accentSoft,
    );
  }

  @override
  RadianUiTheme lerp(ThemeExtension<RadianUiTheme>? other, double t) {
    if (other is! RadianUiTheme) return this;
    return RadianUiTheme(
      surface:       Color.lerp(surface,       other.surface,       t)!,
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textFaint:     Color.lerp(textFaint,     other.textFaint,     t)!,
      divider:       Color.lerp(divider,       other.divider,       t)!,
      border:        Color.lerp(border,        other.border,        t)!,
      success:       Color.lerp(success,       other.success,       t)!,
      warning:       Color.lerp(warning,       other.warning,       t)!,
      accentSoft:    Color.lerp(accentSoft,    other.accentSoft,    t)!,
    );
  }
}

// ── Canvas Theme Extension ────────────────────────────────────────────────────
// Custom extension so widgets can access RADIAN-specific colors
// via Theme.of(context).extension<RadianCanvasTheme>()

class RadianCanvasTheme extends ThemeExtension<RadianCanvasTheme> {
  final Color arm1Color;
  final Color arm2Color;
  final Color resultantColor;
  final Color positiveColor;
  final Color negativeColor;
  final Color canvasBorder;
  final Color gridLine;

  const RadianCanvasTheme({
    required this.arm1Color,
    required this.arm2Color,
    required this.resultantColor,
    required this.positiveColor,
    required this.negativeColor,
    required this.canvasBorder,
    required this.gridLine,
  });

  @override
  RadianCanvasTheme copyWith({
    Color? arm1Color,
    Color? arm2Color,
    Color? resultantColor,
    Color? positiveColor,
    Color? negativeColor,
    Color? canvasBorder,
    Color? gridLine,
  }) {
    return RadianCanvasTheme(
      arm1Color:      arm1Color      ?? this.arm1Color,
      arm2Color:      arm2Color      ?? this.arm2Color,
      resultantColor: resultantColor ?? this.resultantColor,
      positiveColor:  positiveColor  ?? this.positiveColor,
      negativeColor:  negativeColor  ?? this.negativeColor,
      canvasBorder:   canvasBorder   ?? this.canvasBorder,
      gridLine:       gridLine       ?? this.gridLine,
    );
  }

  @override
  RadianCanvasTheme lerp(ThemeExtension<RadianCanvasTheme>? other, double t) {
    if (other is! RadianCanvasTheme) return this;
    return RadianCanvasTheme(
      arm1Color:      Color.lerp(arm1Color,      other.arm1Color,      t)!,
      arm2Color:      Color.lerp(arm2Color,       other.arm2Color,      t)!,
      resultantColor: Color.lerp(resultantColor,  other.resultantColor, t)!,
      positiveColor:  Color.lerp(positiveColor,   other.positiveColor,  t)!,
      negativeColor:  Color.lerp(negativeColor,   other.negativeColor,  t)!,
      canvasBorder:   Color.lerp(canvasBorder,    other.canvasBorder,   t)!,
      gridLine:       Color.lerp(gridLine,         other.gridLine,       t)!,
    );
  }
}

// ── Theme Definitions ─────────────────────────────────────────────────────────

class RadianThemes {

  // ── Obsidian — Default Dark ───────────────────────────────────────────────
  static ThemeData get obsidian => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ObsidianColors.background,

    colorScheme: const ColorScheme.dark(
      background:   ObsidianColors.background,
      surface:      ObsidianColors.surface,
      primary:      ObsidianColors.primary,
      secondary:    ObsidianColors.secondary,
      error:        ObsidianColors.error,
      onBackground: ObsidianColors.textPrimary,
      onSurface:    ObsidianColors.textPrimary,
      onPrimary:    ObsidianColors.background,
      outline:      ObsidianColors.border,
    ),

    textTheme: _buildTextTheme(ObsidianColors.textPrimary, ObsidianColors.textMuted),

    appBarTheme: const AppBarTheme(
      backgroundColor:  ObsidianColors.surface,
      foregroundColor:  ObsidianColors.primary,
      elevation:        0,
      centerTitle:      false,
      titleTextStyle:   TextStyle(
        fontFamily:     'Inter',
        fontSize:       14,
        letterSpacing:  2.5,
        fontWeight:     FontWeight.w700,
        color:          ObsidianColors.primary,
      ),
    ),

    cardTheme: const CardThemeData(
      color:        ObsidianColors.surface,
      elevation:    0,
      margin:       EdgeInsets.zero,
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)), // rounded-2xl — website card radius
        side:         BorderSide(color: ObsidianColors.border),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color:     ObsidianColors.border,
      thickness: 1,
    ),

    elevatedButtonTheme: _elevatedButtonTheme(ObsidianColors.primary, ObsidianColors.background),
    outlinedButtonTheme: _outlinedButtonTheme(ObsidianColors.border, ObsidianColors.textPrimary),
    textButtonTheme:     _textButtonTheme(ObsidianColors.primary),
    inputDecorationTheme: _inputDecorationTheme(
      border: ObsidianColors.border, focused: ObsidianColors.primary,
      fill: ObsidianColors.background, hint: ObsidianColors.textMuted,
    ),

    extensions: const [
      RadianCanvasTheme(
        arm1Color:      ObsidianColors.arm1,
        arm2Color:      ObsidianColors.arm2,
        resultantColor: ObsidianColors.resultant,
        positiveColor:  ObsidianColors.positive,
        negativeColor:  ObsidianColors.negative,
        canvasBorder:   ObsidianColors.border,
        gridLine:       Color(0x1A8B949E), // rgba(139,148,158,0.10)
      ),
      RadianUiTheme(
        surface:       ObsidianColors.surface,
        textPrimary:   ObsidianColors.textPrimary,
        textSecondary: ObsidianColors.textMuted,
        textFaint:     Color(0xB88B949E), // ObsidianColors.textMuted @ ~72%
        divider:       Color(0x9930363D), // ObsidianColors.border @ ~60%
        border:        ObsidianColors.border,
        success:       ObsidianColors.secondary,
        warning:       ObsidianColors.resultant,
        accentSoft:    Color(0x8058A6FF), // ObsidianColors.primary @ ~50%
      ),
    ],
  );

  // ── Vernier — Light ───────────────────────────────────────────────────────
  static ThemeData get vernier => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: VernierColors.bg,

    colorScheme: const ColorScheme.light(
      background:   VernierColors.bg,
      surface:      VernierColors.white,
      primary:      VernierColors.navy,
      secondary:    VernierColors.coral,
      error:        VernierColors.coral,
      onBackground: VernierColors.ink,
      onSurface:    VernierColors.ink,
      onPrimary:    VernierColors.white,
      outline:      VernierColors.lineStrong,
    ),

    textTheme: _buildTextTheme(VernierColors.ink, VernierColors.inkSoft),

    appBarTheme: const AppBarTheme(
      backgroundColor:  VernierColors.white,
      foregroundColor:  VernierColors.navy,
      elevation:        0,
      centerTitle:      false,
      titleTextStyle:   TextStyle(
        fontFamily:     'Inter',
        fontSize:       14,
        letterSpacing:  2.5,
        fontWeight:     FontWeight.w700,
        color:          VernierColors.navy,
      ),
    ),

    cardTheme: const CardThemeData(
      color:        VernierColors.white,
      elevation:    0,
      margin:       EdgeInsets.zero,
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)), // rounded-2xl — website card radius
        side:         BorderSide(color: VernierColors.line),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color:     VernierColors.line,
      thickness: 1,
    ),

    elevatedButtonTheme: _elevatedButtonTheme(VernierColors.navy, VernierColors.white),
    outlinedButtonTheme: _outlinedButtonTheme(VernierColors.lineStrong, VernierColors.ink),
    textButtonTheme:     _textButtonTheme(VernierColors.navy),
    inputDecorationTheme: _inputDecorationTheme(
      border: VernierColors.lineStrong, focused: VernierColors.navy,
      fill: VernierColors.bg, hint: VernierColors.inkFaint,
    ),

    extensions: const [
      RadianCanvasTheme(
        arm1Color:      VernierColors.coral,
        arm2Color:      VernierColors.teal,
        resultantColor: VernierColors.amber,
        positiveColor:  VernierColors.navy,
        negativeColor:  VernierColors.coral,
        canvasBorder:   VernierColors.navySoft,
        gridLine:       VernierColors.line,
      ),
      RadianUiTheme(
        surface:       VernierColors.white,
        textPrimary:   VernierColors.ink,
        textSecondary: VernierColors.inkSoft,
        textFaint:     VernierColors.inkFaint,
        divider:       VernierColors.line,
        border:        VernierColors.lineStrong,
        success:       VernierColors.teal,
        warning:       VernierColors.amber,
        accentSoft:    VernierColors.navySoft,
      ),
    ],
  );

  // ── Shared Button / Input Shapes ──────────────────────────────────────────
  // Radius (12 = rounded-xl) and padding mirror the website's CTA/input classes
  // (px-8 py-3.5 for primary buttons, px-4 py-3 for inputs — see Hero.tsx,
  // WaitlistForm.tsx). Hover/press feedback comes from Material's built-in
  // ink overlay on ElevatedButton/OutlinedButton/InkWell.

  static ElevatedButtonThemeData _elevatedButtonTheme(Color bg, Color fg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(Color border, Color fg) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: border),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color fg) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: fg,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color border,
    required Color focused,
    required Color fill,
    required Color hint,
  }) {
    final radius = BorderRadius.circular(12);
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(fontFamily: 'Inter', color: hint, fontSize: 14),
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: focused, width: 1.5)),
    );
  }

  // ── Shared Text Theme ─────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color muted) {
    return TextTheme(
      titleLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 18,
        fontWeight: FontWeight.w600, color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 16,
        fontWeight: FontWeight.w500, color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 14,
        fontWeight: FontWeight.w400, color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 14,
        fontWeight: FontWeight.w400, color: muted,
      ),
      displayLarge: TextStyle(
        fontFamily: 'JetBrainsMono', fontSize: 34,
        fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.3,
      ),
      displayMedium: TextStyle(
        fontFamily: 'JetBrainsMono', fontSize: 19,
        fontWeight: FontWeight.w600, color: primary,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter', fontSize: 10.5,
        fontWeight: FontWeight.w600, color: muted, letterSpacing: 0.3,
      ),
    );
  }
}

// ── Theme Enum ────────────────────────────────────────────────────────────────

enum RadianThemeMode { obsidian, vernier }

extension RadianThemeModeExtension on RadianThemeMode {
  ThemeData get themeData {
    switch (this) {
      case RadianThemeMode.obsidian: return RadianThemes.obsidian;
      case RadianThemeMode.vernier:  return RadianThemes.vernier;
    }
  }

  Brightness get brightness {
    switch (this) {
      case RadianThemeMode.obsidian: return Brightness.dark;
      case RadianThemeMode.vernier:  return Brightness.light;
    }
  }

  String get displayName {
    switch (this) {
      case RadianThemeMode.obsidian: return 'Obsidian';
      case RadianThemeMode.vernier:  return 'Vernier';
    }
  }

  String get description {
    switch (this) {
      case RadianThemeMode.obsidian: return 'Dark Precision Instrument';
      case RadianThemeMode.vernier:  return 'Precision Angle Instrument';
    }
  }
}
