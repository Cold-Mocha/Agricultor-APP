import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';

abstract final class AgroTheme {
  static ThemeData get light {
    const colors = ColorScheme(
      brightness: Brightness.light,
      primary: AgroColors.brand,
      onPrimary: AgroColors.surface,
      primaryContainer: AgroColors.greenSoft,
      onPrimaryContainer: AgroColors.brandDark,
      secondary: AgroColors.accent,
      onSecondary: AgroColors.brandDark,
      secondaryContainer: AgroColors.accentSoft,
      onSecondaryContainer: AgroColors.brandDark,
      tertiary: AgroColors.sky,
      onTertiary: AgroColors.surface,
      tertiaryContainer: AgroColors.skySoft,
      onTertiaryContainer: AgroColors.skyDark,
      error: AgroColors.rose,
      onError: AgroColors.surface,
      errorContainer: AgroColors.roseSoft,
      onErrorContainer: AgroColors.roseDark,
      surface: AgroColors.surface,
      onSurface: AgroColors.ink,
      onSurfaceVariant: AgroColors.muted,
      outline: AgroColors.line,
      outlineVariant: AgroColors.greenSoft,
      shadow: Color(0x1A17372B),
      scrim: Color(0x6617372B),
      inverseSurface: AgroColors.ink,
      onInverseSurface: AgroColors.surface,
      inversePrimary: AgroColors.brandSoft,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      fontFamily: 'Inter',
    );
    return base.copyWith(
      scaffoldBackgroundColor: AgroColors.surface,
      textTheme: _textTheme(base.textTheme),
      extensions: const [
        AgroSemanticColors(
          success: AgroColors.greenSoft,
          onSuccess: AgroColors.brand,
          warning: AgroColors.amberSoft,
          onWarning: AgroColors.amberDark,
          info: AgroColors.skySoft,
          onInfo: AgroColors.skyDark,
          error: AgroColors.roseSoft,
          onError: AgroColors.roseDark,
        ),
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: AgroColors.surface,
        foregroundColor: AgroColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AgroColors.surface,
        elevation: AgroElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AgroRadii.large),
          side: const BorderSide(color: AgroColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AgroSizes.touchTarget, AgroSizes.touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AgroRadii.large),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AgroSizes.touchTarget, AgroSizes.touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AgroRadii.large),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AgroSizes.touchTarget, AgroSizes.touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AgroRadii.large),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AgroColors.surface,
        constraints: const BoxConstraints(minHeight: 56),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AgroRadii.large),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AgroRadii.large),
          borderSide: const BorderSide(color: AgroColors.line),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 80,
        backgroundColor: AgroColors.surface,
        indicatorColor: AgroColors.greenSoft,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) => base
      .copyWith(
        displayLarge: const TextStyle(
          fontSize: 38,
          height: 44 / 38,
          fontWeight: FontWeight.w900,
        ),
        displayMedium: const TextStyle(
          fontSize: 32,
          height: 38 / 32,
          fontWeight: FontWeight.w900,
        ),
        headlineLarge: const TextStyle(
          fontSize: 28,
          height: 34 / 28,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          height: 30 / 24,
          fontWeight: FontWeight.w900,
        ),
        headlineSmall: const TextStyle(
          fontSize: 22,
          height: 28 / 22,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          height: 26 / 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w800,
        ),
        titleSmall: const TextStyle(
          fontSize: 15,
          height: 20 / 15,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w800,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w800,
        ),
        labelSmall: const TextStyle(
          fontSize: 11,
          height: 16 / 11,
          fontWeight: FontWeight.w800,
        ),
      )
      .apply(bodyColor: AgroColors.ink, displayColor: AgroColors.ink);
}
