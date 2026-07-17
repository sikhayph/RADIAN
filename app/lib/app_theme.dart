import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RADIAN App Themes
// Sikhay and Valiger Collaboration
// Three themes: Obsidian (dark), Chalk (light), Sikhay (branded dark)
// ─────────────────────────────────────────────────────────────────────────────

// ── Color Palettes ───────────────────────────────────────────────────────────

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

class ChalkColors {
  static const background   = Color(0xFFFAFAFA);
  static const surface      = Color(0xFFF0F2F5);
  static const border       = Color(0xFFD0D7DE);
  static const primary      = Color(0xFF0969DA);
  static const secondary    = Color(0xFF1A7F64);
  static const arm1         = Color(0xFFCF222E);
  static const arm2         = Color(0xFF116329);
  static const resultant    = Color(0xFF9A6700);
  static const textPrimary  = Color(0xFF1F2328);
  static const textMuted    = Color(0xFF656D76);
  static const positive     = Color(0xFF0969DA);
  static const negative     = Color(0xFFCF222E);
  static const error        = Color(0xFFCF222E);
}

class SikhayColors {
  static const background   = Color(0xFF0A0A0A);
  static const surface      = Color(0xFF141414);
  static const border       = Color(0xFF2A2A2A);
  static const primary      = Color(0xFFFFFFFF);
  static const secondary    = Color(0xFFAAAAAA);
  static const arm1         = Color(0xFFFFFFFF);
  static const arm2         = Color(0xFFAAAAAA);
  static const resultant    = Color(0xFFE0E0E0);
  static const textPrimary  = Color(0xFFFFFFFF);
  static const textMuted    = Color(0xFF888888);
  static const positive     = Color(0xFFFFFFFF);
  static const negative     = Color(0xFFAAAAAA);
  static const error        = Color(0xFFFF4444);
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

  // ── 1. Obsidian — Default Dark ─────────────────────────────────────────────
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
      foregroundColor:  ObsidianColors.textPrimary,
      elevation:        0,
      centerTitle:      false,
      titleTextStyle:   TextStyle(
        fontFamily:     'Inter',
        fontSize:       18,
        fontWeight:     FontWeight.w600,
        color:          ObsidianColors.textPrimary,
      ),
    ),

    cardTheme: const CardThemeData(
      color:        ObsidianColors.surface,
      elevation:    0,
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side:         BorderSide(color: ObsidianColors.border),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color:     ObsidianColors.border,
      thickness: 1,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ObsidianColors.primary,
        foregroundColor: ObsidianColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
      ),
    ),

    extensions: const [
      RadianCanvasTheme(
        arm1Color:      ObsidianColors.arm1,
        arm2Color:      ObsidianColors.arm2,
        resultantColor: ObsidianColors.resultant,
        positiveColor:  ObsidianColors.positive,
        negativeColor:  ObsidianColors.negative,
        canvasBorder:   ObsidianColors.border,
        gridLine:       Color(0x1A8B949E),
      ),
    ],
  );

  // ── 2. Chalk — Light / Classroom ──────────────────────────────────────────
  static ThemeData get chalk => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ChalkColors.background,

    colorScheme: const ColorScheme.light(
      background:   ChalkColors.background,
      surface:      ChalkColors.surface,
      primary:      ChalkColors.primary,
      secondary:    ChalkColors.secondary,
      error:        ChalkColors.error,
      onBackground: ChalkColors.textPrimary,
      onSurface:    ChalkColors.textPrimary,
      onPrimary:    Colors.white,
      outline:      ChalkColors.border,
    ),

    textTheme: _buildTextTheme(ChalkColors.textPrimary, ChalkColors.textMuted),

    appBarTheme: const AppBarTheme(
      backgroundColor:  ChalkColors.background,
      foregroundColor:  ChalkColors.textPrimary,
      elevation:        0,
      centerTitle:      false,
      titleTextStyle:   TextStyle(
        fontFamily:     'Inter',
        fontSize:       18,
        fontWeight:     FontWeight.w600,
        color:          ChalkColors.textPrimary,
      ),
    ),

    cardTheme: const CardThemeData(
      color:        ChalkColors.surface,
      elevation:    0,
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side:         BorderSide(color: ChalkColors.border),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color:     ChalkColors.border,
      thickness: 1,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ChalkColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
      ),
    ),

    extensions: const [
      RadianCanvasTheme(
        arm1Color:      ChalkColors.arm1,
        arm2Color:      ChalkColors.arm2,
        resultantColor: ChalkColors.resultant,
        positiveColor:  ChalkColors.positive,
        negativeColor:  ChalkColors.negative,
        canvasBorder:   ChalkColors.border,
        gridLine:       Color(0x1A656D76),
      ),
    ],
  );

  // ── 3. Sikhay — Branded Dark ──────────────────────────────────────────────
  static ThemeData get sikhay => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SikhayColors.background,

    colorScheme: const ColorScheme.dark(
      background:   SikhayColors.background,
      surface:      SikhayColors.surface,
      primary:      SikhayColors.primary,
      secondary:    SikhayColors.secondary,
      error:        SikhayColors.error,
      onBackground: SikhayColors.textPrimary,
      onSurface:    SikhayColors.textPrimary,
      onPrimary:    SikhayColors.background,
      outline:      SikhayColors.border,
    ),

    textTheme: _buildTextTheme(SikhayColors.textPrimary, SikhayColors.textMuted),

    appBarTheme: const AppBarTheme(
      backgroundColor:  SikhayColors.surface,
      foregroundColor:  SikhayColors.textPrimary,
      elevation:        0,
      centerTitle:      false,
      titleTextStyle:   TextStyle(
        fontFamily:     'Inter',
        fontSize:       18,
        fontWeight:     FontWeight.w600,
        color:          SikhayColors.textPrimary,
      ),
    ),

    cardTheme: const CardThemeData(
      color:        SikhayColors.surface,
      elevation:    0,
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side:         BorderSide(color: SikhayColors.border),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color:     SikhayColors.border,
      thickness: 1,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SikhayColors.primary,
        foregroundColor: SikhayColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
      ),
    ),

    extensions: const [
      RadianCanvasTheme(
        arm1Color:      SikhayColors.arm1,
        arm2Color:      SikhayColors.arm2,
        resultantColor: SikhayColors.resultant,
        positiveColor:  SikhayColors.positive,
        negativeColor:  SikhayColors.negative,
        canvasBorder:   SikhayColors.border,
        gridLine:       Color(0x1A888888),
      ),
    ],
  );

  // ── Shared Text Theme ─────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color muted) {
    return TextTheme(
      // Mode name header
      titleLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 18,
        fontWeight: FontWeight.w600, color: primary,
      ),
      // Section labels
      titleMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 16,
        fontWeight: FontWeight.w500, color: primary,
      ),
      // Body
      bodyLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 14,
        fontWeight: FontWeight.w400, color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 14,
        fontWeight: FontWeight.w400, color: muted,
      ),
      // Live angle readout — monospace, large
      displayLarge: TextStyle(
        fontFamily: 'JetBrainsMono', fontSize: 32,
        fontWeight: FontWeight.w700, color: primary,
      ),
      // Matrix values — monospace, medium
      displayMedium: TextStyle(
        fontFamily: 'JetBrainsMono', fontSize: 14,
        fontWeight: FontWeight.w500, color: primary,
      ),
      // Canvas labels — small
      labelSmall: TextStyle(
        fontFamily: 'Inter', fontSize: 12,
        fontWeight: FontWeight.w400, color: muted,
      ),
    );
  }
}

// ── Theme Enum ────────────────────────────────────────────────────────────────

enum RadianThemeMode { obsidian, chalk, sikhay }

extension RadianThemeModeExtension on RadianThemeMode {
  ThemeData get themeData {
    switch (this) {
      case RadianThemeMode.obsidian: return RadianThemes.obsidian;
      case RadianThemeMode.chalk:    return RadianThemes.chalk;
      case RadianThemeMode.sikhay:   return RadianThemes.sikhay;
    }
  }

  String get displayName {
    switch (this) {
      case RadianThemeMode.obsidian: return 'Obsidian';
      case RadianThemeMode.chalk:    return 'Chalk';
      case RadianThemeMode.sikhay:   return 'Sikhay';
    }
  }

  String get description {
    switch (this) {
      case RadianThemeMode.obsidian: return 'Dark — best for extended classroom sessions';
      case RadianThemeMode.chalk:    return 'Light — best for projected displays';
      case RadianThemeMode.sikhay:   return 'Branded — for demos and presentations';
    }
  }
}
