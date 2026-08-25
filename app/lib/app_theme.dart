import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RADIAN App Themes
// Sikhay and Valiger Collaboration
// Three themes: Obsidian (dark), Chalk (light), Sikhay (branded dark)
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
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side:         BorderSide(color: VernierColors.line),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color:     VernierColors.line,
      thickness: 1,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VernierColors.navy,
        foregroundColor: VernierColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
      ),
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
    ],
  );

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

enum RadianThemeMode { vernier }

extension RadianThemeModeExtension on RadianThemeMode {
  ThemeData get themeData {
    switch (this) {
      case RadianThemeMode.vernier: return RadianThemes.vernier;
    }
  }

  String get displayName {
    switch (this) {
      case RadianThemeMode.vernier: return 'Vernier';
    }
  }

  String get description {
    switch (this) {
      case RadianThemeMode.vernier: return 'Precision Angle Instrument';
    }
  }
}
