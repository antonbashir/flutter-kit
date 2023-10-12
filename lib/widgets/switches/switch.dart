import 'package:flutter/material.dart';

import '../../../theme/common.dart';

class CustomSwitch extends StatelessWidget {
  final IconData? icon;
  final void Function(bool value)? onChanged;
  final bool value;
  final MaterialStateProperty<Color>? trackColor;

  const CustomSwitch({
    super.key,
    this.icon,
    this.onChanged,
    required this.value,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    return Switch(
      thumbIcon: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          if (states.contains(MaterialState.selected)) {
            return isDark ? Icon(icon, color: surface) : Icon(icon, color: primary);
          }
          return isDark ? Icon(icon, color: primary) : Icon(icon, color: surface);
        }
        if (states.contains(MaterialState.selected)) {
          return isDark ? Icon(icon, color: surface) : Icon(icon, color: primary);
        }
        return isDark ? Icon(icon, color: primary) : Icon(icon, color: surface);
      }),
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          if (states.contains(MaterialState.selected)) {
            return isDark ? primary : surface;
          }
          return isDark ? surface : primary;
        }
        if (states.contains(MaterialState.selected)) {
          return isDark ? primary : surface;
        }
        return isDark ? surface : primary;
      }),
      value: value,
      onChanged: onChanged,
      trackColor: trackColor == null
          ? null
          : MaterialStateColor.resolveWith(
              (states) {
                if (states.contains(MaterialState.disabled)) {
                  return trackColor!.resolve(states).withOpacity(CommonThemeColors.disabledOpacity);
                }
                return trackColor!.resolve(states);
              },
            ),
    );
  }
}
