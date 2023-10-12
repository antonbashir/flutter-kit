import 'package:flutter/material.dart';

import '../constants/fonts.dart';
import '../constants/sizes.dart';
import 'common.dart';

class LightThemeColors {
  static final _primarySwatch = {
    50: const Color.fromRGBO(0, 0, 0, .1),
    100: const Color.fromRGBO(0, 0, 0, .2),
    200: const Color.fromRGBO(0, 0, 0, .3),
    300: const Color.fromRGBO(0, 0, 0, .4),
    400: const Color.fromRGBO(0, 0, 0, .5),
    500: const Color.fromRGBO(0, 0, 0, .6),
    600: const Color.fromRGBO(0, 0, 0, .7),
    700: const Color.fromRGBO(0, 0, 0, .8),
    800: const Color.fromRGBO(0, 0, 0, .9),
    900: const Color.fromRGBO(0, 0, 0, 1),
  };
  static const secondary = Color(0xffCAE3F5);
  static const tertiary = Colors.teal;
  static final primary = MaterialColor(0xFF000000, _primarySwatch);
  static const surface = Colors.white;
  static const background = Colors.white;

  static const success = CommonThemeColors.success;
  static const error = CommonThemeColors.error;
  static const warning = CommonThemeColors.warning;
  static const info = CommonThemeColors.info;

  LightThemeColors._();
}

final _base = ThemeData(
  primarySwatch: LightThemeColors.primary,
  fontFamily: textFont,
  brightness: Brightness.light,
  useMaterial3: true,
  scaffoldBackgroundColor: LightThemeColors.background,
  dialogBackgroundColor: LightThemeColors.background,
);

final colors = ColorScheme.light(
  primary: LightThemeColors.primary,
  secondary: LightThemeColors.secondary,
  tertiary: LightThemeColors.tertiary,
  surface: LightThemeColors.surface,
  surfaceVariant: LightThemeColors.surface,
  onSurface: Colors.black,
  error: CommonThemeColors.error,
);

final materialLightTheme = _base.copyWith(
  brightness: Brightness.light,
  colorScheme: colors,
  tabBarTheme: TabBarTheme(
    labelColor: LightThemeColors.primary,
  ),
  appBarTheme: AppBarTheme(
    iconTheme: IconThemeData(
      color: LightThemeColors.primary,
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
    inactiveTrackColor: LightThemeColors.primary.shade100,
  ),
  progressIndicatorTheme: _base.progressIndicatorTheme.copyWith(
    linearTrackColor: LightThemeColors.primary.shade100,
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
    fillColor: ElevationOverlay.colorWithOverlay(LightThemeColors.surface, _base.colorScheme.onSurface, 1),
  ),
  dividerTheme: const DividerThemeData(thickness: Sizes.dividerThickness),
  datePickerTheme: _base.datePickerTheme.copyWith(
    rangePickerShape: RoundedRectangleBorder(borderRadius: strongBorder),
    rangeSelectionBackgroundColor: LightThemeColors.primary.shade100,
  ),
  dialogTheme: _base.dialogTheme.copyWith(
    shape: RoundedRectangleBorder(borderRadius: strongBorder),
  ),
);