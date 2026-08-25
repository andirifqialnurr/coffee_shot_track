import 'package:flutter/material.dart';

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
