import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF0B6BD9);
  static const primarySoft = Color(0xFFE7F1FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5F7FA);
  static const codeSurface = Color(0xFFEDEFF3);
  static const ink = Color(0xFF111318);
  static const muted = Color(0xFF667085);
  static const outline = Color(0xFFD9DEE7);
  static const avatarForeground = Color(0xFF83B7F8);
  static const success = Color(0xFF2DAA47);
  static const successInk = Color(0xFF287A38);
  static const successSoft = Color(0xFFEAF8E8);
  static const warning = Color(0xFFF6BE2C);
  static const warningInk = Color(0xFF8A6100);
  static const warningSoft = Color(0xFFFFF4D6);
  static const errorInk = Color(0xFFB42318);
  static const errorSoft = Color(0xFFFDECEC);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
}

abstract final class AppRadius {
  static const xs = 8.0;
  static const sm = 10.0;
  static const md = 12.0;
  static const lg = 14.0;
  static const pill = 999.0;
}

abstract final class AppSize {
  static const primaryButtonHeight = 52.0;
}

abstract final class AppTheme {
  static ThemeData get light => _build();

  @visibleForTesting
  static ThemeData withFont(String fontFamily) {
    return _build(fontFamily: fontFamily);
  }

  static ThemeData _build({String? fontFamily}) {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onSurface: AppColors.ink,
      outline: AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: fontFamily,
      fontFamilyFallback: const ['SF Pro Text', 'Roboto'],
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          height: 1.18,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(fontSize: 14, height: 1.32),
        bodySmall: TextStyle(fontSize: 12, height: 1.3, color: AppColors.muted),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          fontFamily: fontFamily,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            kMinInteractiveDimension,
            AppSize.primaryButtonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
    );
  }
}
