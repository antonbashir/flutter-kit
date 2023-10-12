import 'package:flutter/material.dart';

import '../constants/fonts.dart';
import '../constants/sizes.dart';
import 'common.dart';

class DarkThemeColors {
  static final _primarySwatch = {
    50: const Color.fromRGBO(255, 255, 255, .1),
    100: const Color.fromRGBO(255, 255, 255, .2),
    200: const Color.fromRGBO(255, 255, 255, .3),
    300: const Color.fromRGBO(255, 255, 255, .4),
    400: const Color.fromRGBO(255, 255, 255, .5),
    500: const Color.fromRGBO(255, 255, 255, .6),
    600: const Color.fromRGBO(255, 255, 255, .7),
    700: const Color.fromRGBO(255, 255, 255, .8),
    800: const Color.fromRGBO(255, 255, 255, .9),
    900: const Color.fromRGBO(255, 255, 255, 1),
  };
  static const secondary = Color(0xff8FDEEA);
  static const tertiary = Colors.teal;
  static final primary = MaterialColor(0xFFFFFFFF, _primarySwatch);
  static const surface = Color(0xFF1F2226);
  static const success = CommonThemeColors.success;
  static const error = CommonThemeColors.error;
  static const warning = CommonThemeColors.warning;
  static const info = CommonThemeColors.info;

  DarkThemeColors._();
}

final _base = ThemeData(
  primarySwatch: DarkThemeColors.primary,
  fontFamily: textFont,
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: DarkThemeColors.surface,
  dialogBackgroundColor: DarkThemeColors.surface,
);

final colors = ColorScheme.dark(
  primary: DarkThemeColors.primary,
  secondary: DarkThemeColors.secondary,
  tertiary: DarkThemeColors.tertiary,
  onError: DarkThemeColors.primary,
  error: CommonThemeColors.error,
  surface: DarkThemeColors.surface,
  surfaceVariant: DarkThemeColors.surface,
);

final materialDarkTheme = _base.copyWith(
  brightness: Brightness.dark,
  colorScheme: colors,
  tabBarTheme: TabBarTheme(
    labelColor: DarkThemeColors.primary,
  ),
  appBarTheme: AppBarTheme(
    iconTheme: IconThemeData(
      color: DarkThemeColors.primary,
    ),
  ),
  navigationBarTheme: _base.navigationBarTheme.copyWith(
    indicatorShape: RoundedRectangleBorder(borderRadius: strongBorder),
  ),
  navigationRailTheme: _base.navigationRailTheme.copyWith(
    indicatorShape: RoundedRectangleBorder(borderRadius: strongBorder),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  splashFactory: NoSplash.splashFactory,
  sliderTheme: _base.sliderTheme.copyWith(
    inactiveTrackColor: DarkThemeColors.primary.shade100,
  ),
  progressIndicatorTheme: _base.progressIndicatorTheme.copyWith(
    linearTrackColor: DarkThemeColors.primary.shade100,
  ),
  chipTheme: _base.chipTheme.copyWith(
    deleteIconColor: DarkThemeColors.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: strongBorder,
          side: BorderSide.none,
        ),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: strongBorder,
          side: BorderSide.none,
        ),
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: strongBorder,
          side: BorderSide.none,
        ),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: ElevationOverlay.colorWithOverlay(DarkThemeColors.surface, _base.colorScheme.onSurface, 1),
  ),
  dividerTheme: const DividerThemeData(thickness: Sizes.dividerThickness),
  datePickerTheme: _base.datePickerTheme.copyWith(
    rangePickerShape: RoundedRectangleBorder(borderRadius: strongBorder),
    rangeSelectionBackgroundColor: DarkThemeColors.primary.shade100,
  ),
  dialogTheme: _base.dialogTheme.copyWith(
    shape: RoundedRectangleBorder(borderRadius: strongBorder),
  ),
);
