import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

// ignore: prefer_mixin
class SizeResponseProvider with ChangeNotifier {
  void notify(Function action) {
    action();
    notifyListeners();
  }

  final double initialDesktopWidth = 1024;
  final double initialTabletWidth = 768;
  final double initialPhoneWidth = 360;

  late double desktopWidth;
  late double tabletWidth;
  late double phoneWidth;

  final ScrollController scrollController = ScrollController();

  bool _resizingInProgress = false;

  late ScreenType _screenType;

  ScreenType get screenType => _screenType;

  late double _screenWidth;

  late double _scale;

  late double _throughScale;

  late double pixelRatio;

  double get vw => _screenWidth / 100;

  double get screenWidth => _screenWidth;

  double get scale => _scale;

  double get throughScale => _throughScale;

  void _setScale() {
    double baseWidth = desktopWidth;
    if (_screenType == ScreenType.tablet) {
      baseWidth = tabletWidth;
    }
    if (_screenType == ScreenType.mobile) {
      baseWidth = phoneWidth;
    }
    _scale = double.parse((_screenWidth / baseWidth).toStringAsFixed(4));
    _throughScale = _screenWidth / desktopWidth;
  }

  void _setScreenWidth(double width) {
    _screenWidth = width;
    if (width >= desktopWidth && _screenType != ScreenType.desktop) {
      _screenType = ScreenType.desktop;
    } else if (width <= tabletWidth && _screenType != ScreenType.mobile) {
      _screenType = ScreenType.mobile;
    } else if (width > tabletWidth &&
        width < desktopWidth &&
        _screenType != ScreenType.tablet) {
      _screenType = ScreenType.tablet;
    }
  }

  void init(double width, double pixRatio) {
    _resizingInProgress = true;
    pixelRatio = pixRatio;
    desktopWidth = initialDesktopWidth * pixelRatio;
    tabletWidth = initialTabletWidth * pixelRatio;
    phoneWidth = initialPhoneWidth * pixelRatio;
    _screenWidth = width;
    if (width >= tabletWidth) {
      _screenType = ScreenType.desktop;
    } else if (width <= phoneWidth) {
      _screenType = ScreenType.mobile;
    } else {
      _screenType = ScreenType.tablet;
    }
    _setScale();
    _resizingInProgress = false;
  }

  void onScreenWidthChange(double width, double pixRatio) {
    if (!_resizingInProgress) {
      _resizingInProgress = true;
      notify(() {
        if (width != _screenWidth) {
          pixelRatio = pixRatio;
          _setScreenWidth(width);
          _setScale();
        }
      });
    }
    _resizingInProgress = false;
  }
}
