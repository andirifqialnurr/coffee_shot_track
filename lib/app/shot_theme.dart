import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart' as shad;

class ShotColors extends ThemeExtension<ShotColors> {
  const ShotColors({
    required this.caramel,
    required this.success,
    required this.mutedText,
    required this.cardBorder,
  });

  final Color caramel;
  final Color success;
  final Color mutedText;
  final Color cardBorder;

  @override
  ShotColors copyWith({
    Color? caramel,
    Color? success,
    Color? mutedText,
    Color? cardBorder,
  }) {
    return ShotColors(
      caramel: caramel ?? this.caramel,
      success: success ?? this.success,
      mutedText: mutedText ?? this.mutedText,
      cardBorder: cardBorder ?? this.cardBorder,
    );
  }

  @override
  ShotColors lerp(ThemeExtension<ShotColors>? other, double t) {
    if (other is! ShotColors) {
      return this;
    }
    return ShotColors(
      caramel: Color.lerp(caramel, other.caramel, t)!,
      success: Color.lerp(success, other.success, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
    );
  }
}

class _ShotPalette {
  const _ShotPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.success,
    required this.destructive,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color border;
  final Color input;
  final Color ring;
  final Color success;
  final Color destructive;
}

class ShotTheme {
  static const _lightPalette = _ShotPalette(
    background: Color(0xFFFAFAF9),
    foreground: Color(0xFF18181B),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF27272A),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFF4F4F5),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFFFF7ED),
    accentForeground: Color(0xFF9A3412),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFFD97706),
    success: Color(0xFF15803D),
    destructive: Color(0xFFDC2626),
  );

  static const _darkPalette = _ShotPalette(
    background: Color(0xFF09090B),
    foreground: Color(0xFFFAFAFA),
    card: Color(0xFF18181B),
    primary: Color(0xFFFAFAFA),
    onPrimary: Color(0xFF18181B),
    secondary: Color(0xFF27272A),
    muted: Color(0xFF27272A),
    mutedForeground: Color(0xFFA1A1AA),
    accent: Color(0xFF431407),
    accentForeground: Color(0xFFFED7AA),
    border: Color(0xFF27272A),
    input: Color(0xFF3F3F46),
    ring: Color(0xFFF59E0B),
    success: Color(0xFF4ADE80),
    destructive: Color(0xFFF87171),
  );

  static shad.ShadThemeData shadLight() {
    return _shad(Brightness.light, _lightPalette);
  }

  static shad.ShadThemeData shadDark() {
    return _shad(Brightness.dark, _darkPalette);
  }

  static ThemeData light() {
    return _build(Brightness.light, _lightPalette);
  }

  static ThemeData dark() {
    return _build(Brightness.dark, _darkPalette);
  }

  static shad.ShadThemeData _shad(Brightness brightness, _ShotPalette palette) {
    final colorScheme = brightness == Brightness.dark
        ? shad.ShadZincColorScheme.dark(
            background: palette.background,
            foreground: palette.foreground,
            card: palette.card,
            primary: palette.primary,
            primaryForeground: palette.onPrimary,
            secondary: palette.secondary,
            secondaryForeground: palette.foreground,
            muted: palette.muted,
            mutedForeground: palette.mutedForeground,
            accent: palette.accent,
            accentForeground: palette.accentForeground,
            destructive: palette.destructive,
            border: palette.border,
            input: palette.input,
            ring: palette.ring,
          )
        : shad.ShadZincColorScheme.light(
            background: palette.background,
            foreground: palette.foreground,
            card: palette.card,
            primary: palette.primary,
            primaryForeground: palette.onPrimary,
            secondary: palette.secondary,
            secondaryForeground: palette.foreground,
            muted: palette.muted,
            mutedForeground: palette.mutedForeground,
            accent: palette.accent,
            accentForeground: palette.accentForeground,
            destructive: palette.destructive,
            border: palette.border,
            input: palette.input,
            ring: palette.ring,
          );

    return shad.ShadThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      radius: const BorderRadius.all(Radius.circular(8)),
      textTheme: shad.ShadTextTheme.fromGoogleFont(GoogleFonts.montserrat),
      cardTheme: shad.ShadCardTheme(
        backgroundColor: palette.card,
        padding: const EdgeInsets.all(16),
        radius: const BorderRadius.all(Radius.circular(8)),
        border: shad.ShadBorder.all(color: palette.border),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: brightness == Brightness.dark ? 0.18 : 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      primaryButtonTheme: shad.ShadButtonTheme(
        height: 44,
        textStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      outlineButtonTheme: shad.ShadButtonTheme(
        height: 44,
        textStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      ghostButtonTheme: shad.ShadButtonTheme(height: 40),
    );
  }

  static ThemeData _build(Brightness brightness, _ShotPalette palette) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.ring,
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      surface: palette.card,
      error: palette.destructive,
    );

    final baseTextTheme = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final textTheme = GoogleFonts.montserratTextTheme(baseTextTheme)
        .apply(bodyColor: palette.foreground, displayColor: palette.foreground)
        .copyWith(
          displaySmall: GoogleFonts.montserrat(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          headlineMedium: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.12,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          headlineSmall: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.18,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          titleLarge: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          titleMedium: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.25,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          titleSmall: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          bodyMedium: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.45,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          bodySmall: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: 0,
            color: palette.mutedForeground,
          ),
          labelLarge: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          labelMedium: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
            color: palette.foreground,
          ),
          labelSmall: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: 0,
            color: palette.foreground,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: palette.background,
        foregroundColor: palette.foreground,
        titleTextStyle: textTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: palette.mutedForeground,
        ),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: palette.mutedForeground,
        ),
        floatingLabelStyle: textTheme.labelLarge?.copyWith(
          color: palette.ring,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.ring, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.secondary,
        selectedColor: palette.primary,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: palette.foreground,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: palette.onPrimary,
        ),
        side: BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      extensions: [
        ShotColors(
          caramel: palette.ring,
          success: palette.success,
          mutedText: palette.mutedForeground,
          cardBorder: palette.border,
        ),
      ],
    );
  }
}
