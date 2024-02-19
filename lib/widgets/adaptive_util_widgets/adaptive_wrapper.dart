import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/size_response_provider.dart';


class AdaptiveWrapper extends StatelessWidget {
  const AdaptiveWrapper(
      {Key? key,
      this.child,
      this.tabletChild,
      this.mobileChild,
      this.useDesktopOnMobile = false,
      this.useDesktopOnTablet = false})
      : super(key: key);

  final Widget? child;
  final Widget? tabletChild;
  final Widget? mobileChild;
  final bool useDesktopOnTablet;
  final bool useDesktopOnMobile;

  @override
  Widget build(BuildContext context) {
    final screenType = context.watch<SizeResponseProvider>().screenType;
    switch (screenType) {
      case ScreenType.mobile:
        return (useDesktopOnMobile ? child : mobileChild) ??
            const SizedBox.shrink();
      case ScreenType.tablet:
        return (useDesktopOnTablet ? child : tabletChild) ??
            const SizedBox.shrink();
      case ScreenType.desktop:
        return child ?? const SizedBox.shrink();
    }
  }
}
