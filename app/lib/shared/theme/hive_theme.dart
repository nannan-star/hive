import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hive_colors.dart';

abstract final class HiveTheme {
  /// Pages don't use [AppBar], so overlay style must be applied globally.
  static const systemUi = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: HiveColors.card,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: HiveColors.accent,
      onPrimary: HiveColors.onAccent,
      surface: HiveColors.card,
      onSurface: HiveColors.ink,
      secondary: HiveColors.accentSoft,
      onSecondary: HiveColors.accent,
      outline: HiveColors.border,
      error: HiveColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: HiveColors.page,
      canvasColor: HiveColors.page,
      dividerColor: HiveColors.border,
      splashFactory: InkRipple.splashFactory,
      fontFamilyFallback: const [
        'PingFang SC',
        'Noto Sans SC',
        'Noto Sans CJK SC',
        'Hiragino Sans GB',
        'Microsoft YaHei',
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: HiveColors.page,
        foregroundColor: HiveColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemUi,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: HiveColors.accent,
          foregroundColor: HiveColors.onAccent,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HiveColors.muted,
          side: const BorderSide(color: HiveColors.border),
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: HiveColors.muted,
          textStyle: const TextStyle(fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HiveColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HiveColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HiveColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HiveColors.accent),
        ),
        labelStyle: const TextStyle(color: HiveColors.dim, fontSize: 13),
        hintStyle: const TextStyle(color: HiveColors.dim, fontSize: 15),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return HiveColors.card;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HiveColors.accent;
          }
          return HiveColors.track;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HiveColors.ink,
        contentTextStyle: const TextStyle(color: HiveColors.card),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: HiveColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: HiveColors.card,
        headerBackgroundColor: HiveColors.accentSoft,
        headerForegroundColor: HiveColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: HiveColors.accent,
      ),
    );
  }
}
