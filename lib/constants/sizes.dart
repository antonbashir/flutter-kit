import 'package:flutter/material.dart';

class Spacings {
  Spacings._();

  static const small = 4.0;
  static const medium = 8.0;
  static const large = 16.0;
  static const gigantic = 24.0;
}

class Borders {
  Borders._();

  static const cornerWeak = 2.0;
  static const cornerMedium = 4.0;
  static const cornerStrong = 8.0;
}

class Sizes {
  Sizes._();

  static const badgeSize = 18.0;

  static const filterWidth = 350.0;

  static const inputTinyWidth = 150.0;
  static const inputSmallWidth = 250.0;
  static const inputMediumWidth = 350.0;
  static const inputLargeWith = 450.0;

  static const suggestionsHeight = 500.0;

  static const buttonLargeHeight = 44.0;

  static const dividerThickness = 0.3;

  static const progressStrokeWidth = 1.0;
  static const progressIndicatorDefaultSize = 41;

  static const iconsDefaultSize = 41;
}

class Dialogs {
  Dialogs._();

  static const mediumHeight = 500.0;
  static const mediumWidth = 500.0;
  static const smallHeight = 350.0;
  static const smallWidth = 350.0;
  static const tinyHeight = 250.0;
  static const tinyWidth = 250.0;
  static const mediumHeightFactor = 0.45;
  static const mediumWidthFactor = 0.45;
  static const largeHeightFactor = 0.7;
  static const largeWidthFactor = 0.7;
}

final weakBorder = BorderRadius.circular(Borders.cornerWeak);
final mediumBorder = BorderRadius.circular(Borders.cornerMedium);
final strongBorder = BorderRadius.circular(Borders.cornerStrong);
