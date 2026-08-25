import 'package:flutter/material.dart';
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

class ShotTheme {
  static shad.ShadThemeData shadLight() {
    return shad.ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const shad.ShadZincColorScheme.light(
        background: Color(0xFFFAFAFA),
        foreground: Color(0xFF18181B),
        card: Color(0xFFFFFFFF),
        primary: Color(0xFF1F2937),
        primaryForeground: Color(0xFFFFFFFF),
        secondary: Color(0xFFF4F4F5),
        secondaryForeground: Color(0xFF18181B),
        muted: Color(0xFFF4F4F5),
        mutedForeground: Color(0xFF71717A),
        accent: Color(0xFFEFF6FF),
        accentForeground: Color(0xFF1E3A8A),
        border: Color(0xFFE4E4E7),
        input: Color(0xFFE4E4E7),
        ring: Color(0xFFC47A3A),
      ),
      radius: BorderRadius.all(Radius.circular(8)),
    );
  }

  static shad.ShadThemeData shadDark() {
    return shad.ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const shad.ShadZincColorScheme.dark(
        background: Color(0xFF09090B),
        foreground: Color(0xFFFAFAFA),
        card: Color(0xFF18181B),
        primary: Color(0xFFFAFAFA),
        primaryForeground: Color(0xFF18181B),
        secondary: Color(0xFF27272A),
        secondaryForeground: Color(0xFFFAFAFA),
        muted: Color(0xFF27272A),
        mutedForeground: Color(0xFFA1A1AA),
        accent: Color(0xFF172554),
        accentForeground: Color(0xFFDBEAFE),
        border: Color(0xFF27272A),
        input: Color(0xFF27272A),
        ring: Color(0xFFD5A16A),
      ),
      radius: BorderRadius.all(Radius.circular(8)),
    );
  }

  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      background: const Color(0xFFF8F4EE),
      surface: const Color(0xFFFFFDF8),
      elevated: Colors.white,
      primary: const Color(0xFF5A3825),
      onPrimary: const Color(0xFFFFFDF8),
      caramel: const Color(0xFFC47A3A),
      success: const Color(0xFF5E8C6A),
      ink: const Color(0xFF201A16),
      muted: const Color(0xFF766A60),
      border: const Color(0xFFE5D8C9),
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      background: const Color(0xFF161412),
      surface: const Color(0xFF211D19),
      elevated: const Color(0xFF2C251F),
      primary: const Color(0xFFD5A16A),
      onPrimary: const Color(0xFF161412),
      caramel: const Color(0xFFC98243),
      success: const Color(0xFF83B28C),
      ink: const Color(0xFFF8EEE3),
      muted: const Color(0xFFBBAEA2),
      border: const Color(0xFF463A31),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color elevated,
    required Color primary,
    required Color onPrimary,
    required Color caramel,
    required Color success,
    required Color ink,
    required Color muted,
    required Color border,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
    );

    final baseTextTheme = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      textTheme: baseTextTheme.apply(bodyColor: ink, displayColor: ink),
      cardTheme: CardThemeData(
        elevation: 0,
        color: elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
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
          caramel: caramel,
          success: success,
          mutedText: muted,
          cardBorder: border,
        ),
      ],
    );
  }
}
