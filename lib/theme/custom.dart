import 'package:flutter/material.dart';

class CustomTheme extends ThemeExtension<CustomTheme> {
  CustomTheme();

  static CustomTheme? of(BuildContext context) => Theme.of(context).custom();

  @override
  CustomTheme copyWith() => CustomTheme();

  CustomTheme apply({String? fontFamily}) => copyWith();

  @override
  ThemeExtension<CustomTheme> lerp(ThemeExtension<CustomTheme>? other, double t) => this;
}

extension ThemeDataExtensions on ThemeData {
  CustomTheme? custom() => extension();
}
