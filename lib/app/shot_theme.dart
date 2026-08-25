import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart' as shad;

class ShotColors extends ThemeExtension<ShotColors> {
  const ShotColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.danger,
    required this.success,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color danger;
  final Color success;

  Color get caramel => accent;
  Color get mutedText => textSecondary;
  Color get cardBorder => border;

  @override
  ShotColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? danger,
    Color? success,
  }) {
    return ShotColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      danger: danger ?? this.danger,
      success: success ?? this.success,
    );
  }

  @override
  ShotColors lerp(ThemeExtension<ShotColors>? other, double t) {
    if (other is! ShotColors) {
      return this;
    }
    return ShotColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

class ShotTheme {
  static const lightColors = ShotColors(
    background: Color(0xFFFBF3E8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF2E4D3),
    primary: Color(0xFF4E3221),
    onPrimary: Color(0xFFFBF3E8),
    accent: Color(0xFFC5854A),
    textPrimary: Color(0xFF2B211C),
    textSecondary: Color(0xFF8A7B6E),
    border: Color(0xFFE7D8C4),
    danger: Color(0xFFB3492F),
    success: Color(0xFF3F7A55),
  );

  static const darkColors = ShotColors(
    background: Color(0xFF19140F),
    surface: Color(0xFF241D17),
    surfaceAlt: Color(0xFF2D241C),
    primary: Color(0xFFDFAA6D),
    onPrimary: Color(0xFF241A10),
    accent: Color(0xFFDFAA6D),
    textPrimary: Color(0xFFF3E9DC),
    textSecondary: Color(0xFFAA9C8C),
    border: Color(0xFF3A2F25),
    danger: Color(0xFFE07B5C),
    success: Color(0xFF7EC195),
  );

  static ThemeData light() => _build(Brightness.light, lightColors);

  static ThemeData dark() => _build(Brightness.dark, darkColors);

  static shad.ShadThemeData shadLight() =>
      _shad(Brightness.light, lightColors);

  static shad.ShadThemeData shadDark() => _shad(Brightness.dark, darkColors);

  static shad.ShadThemeData _shad(Brightness brightness, ShotColors colors) {
    final colorScheme = brightness == Brightness.dark
        ? shad.ShadZincColorScheme.dark(
            background: colors.background,
            foreground: colors.textPrimary,
            card: colors.surface,
            primary: colors.primary,
            primaryForeground: colors.onPrimary,
            secondary: colors.surfaceAlt,
            secondaryForeground: colors.textPrimary,
            muted: colors.surfaceAlt,
            mutedForeground: colors.textSecondary,
            accent: colors.surfaceAlt,
            accentForeground: colors.primary,
            destructive: colors.danger,
            border: colors.border,
            input: colors.border,
            ring: colors.accent,
          )
        : shad.ShadZincColorScheme.light(
            background: colors.background,
            foreground: colors.textPrimary,
            card: colors.surface,
            primary: colors.primary,
            primaryForeground: colors.onPrimary,
            secondary: colors.surfaceAlt,
            secondaryForeground: colors.textPrimary,
            muted: colors.surfaceAlt,
            mutedForeground: colors.textSecondary,
            accent: colors.surfaceAlt,
            accentForeground: colors.primary,
            destructive: colors.danger,
            border: colors.border,
            input: colors.border,
            ring: colors.accent,
          );

    return shad.ShadThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      radius: const BorderRadius.all(Radius.circular(16)),
      textTheme: shad.ShadTextTheme.fromGoogleFont(GoogleFonts.montserrat),
    );
  }

  static ThemeData _build(Brightness brightness, ShotColors colors) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.accent,
      onSecondary: colors.onPrimary,
      error: colors.danger,
      onError: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    );

    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final textTheme = GoogleFonts.montserratTextTheme(base)
        .apply(
          bodyColor: colors.textPrimary,
          displayColor: colors.textPrimary,
        )
        .copyWith(
          headlineMedium: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: 0,
            color: colors.textPrimary,
          ),
          headlineSmall: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.18,
            letterSpacing: 0,
            color: colors.textPrimary,
          ),
          titleLarge: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.22,
            letterSpacing: 0,
            color: colors.textPrimary,
          ),
          titleMedium: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: 0,
            color: colors.textPrimary,
          ),
          titleSmall: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: 0,
            color: colors.textPrimary,
          ),
          bodyMedium: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0,
            color: colors.textPrimary,
          ),
          bodySmall: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: 0,
            color: colors.textSecondary,
          ),
          labelLarge: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
            color: colors.textPrimary,
          ),
          labelMedium: GoogleFonts.montserrat(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
            color: colors.textPrimary,
          ),
          labelSmall: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: 0,
            color: colors.textSecondary,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(color: colors.border),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(44, 52),
          elevation: 0,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 50),
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.border, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: textTheme.labelMedium,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surfaceAlt;
        }),
      ),
      extensions: [colors],
    );
  }
}
