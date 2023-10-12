import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../theme/common.dart';

class SelectableTextButton extends StatefulWidget {
  final String text;
  final bool selected;
  final VoidCallback? onClick;
  final TextStyle? textStyle;

  const SelectableTextButton({
    super.key,
    required this.text,
    this.textStyle,
    this.selected = false,
    this.onClick,
  });

  @override
  State<SelectableTextButton> createState() => _SelectableTextButtonState();
}

class _SelectableTextButtonState extends State<SelectableTextButton> {
  late bool _highlight;

  @override
  void initState() {
    super.initState();
    _highlight = widget.selected;
  }

  @override
  void dispose() {
    _highlight = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    final color = _highlight || widget.selected ? onSurfaceColor.withOpacity(1) : onSurfaceColor.withOpacity(CommonThemeColors.highlightOpacity);
    final style = widget.textStyle?.copyWith(color: color) ?? theme.textTheme.bodyLarge?.copyWith(color: color) ?? TextStyle(color: color);
    return MouseRegion(
      onExit: (event) => setState(() => _highlight = false),
      onEnter: (event) => setState(() => _highlight = true),
      cursor: widget.onClick == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onClick,
        behavior: HitTestBehavior.opaque,
        child: widget.selected ? Text("$boldDot ${widget.text}", style: style) : Text(widget.text, style: style),
      ),
    );
  }
}

class SelectableIconButton extends StatefulWidget {
  final Icon unselectedIcon;
  final Icon? selectedIcon;
  final bool selected;
  final bool disabled;
  final void Function(bool select)? onClick;

  const SelectableIconButton({
    super.key,
    required this.unselectedIcon,
    this.selectedIcon,
    this.selected = false,
    this.disabled = false,
    this.onClick,
  });

  @override
  State<SelectableIconButton> createState() => _SelectableIconButtonState();
}

class _SelectableIconButtonState extends State<SelectableIconButton> {
  late bool _highlight;

  @override
  void initState() {
    super.initState();
    _highlight = widget.selected;
  }

  @override
  void dispose() {
    _highlight = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme.primary;
    return IconButton(
      style: _highlight
          ? ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                theme.withOpacity(CommonThemeColors.highlightOpacity),
              ),
            )
          : null,
      onPressed: widget.disabled
          ? null
          : () {
              setState(() => _highlight = !_highlight);
              widget.onClick?.call(!_highlight);
            },
      icon: _highlight ? (widget.selectedIcon ?? widget.unselectedIcon) : widget.unselectedIcon,
    );
  }
}
