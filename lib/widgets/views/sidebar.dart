import 'package:flutter/material.dart';

class SmallSidebar extends StatefulWidget {
  final List<NavigationRailDestination> destinations;
  final Widget Function(int index) contentBuilder;
  final double? minWidth;
  final double? minExtendedWidth;
  final Widget? title;
  final bool extended;
  final EdgeInsets? dividerPadding;

  const SmallSidebar({
    super.key,
    required this.destinations,
    required this.contentBuilder,
    this.minWidth,
    this.minExtendedWidth,
    this.extended = false,
    this.title,
    this.dividerPadding,
  });

  @override
  State<SmallSidebar> createState() => _SmallSidebarState();
}

class _SmallSidebarState extends State<SmallSidebar> {
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    Widget navRail = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.minHeight),
          child: IntrinsicHeight(
            child: NavigationRail(
              destinations: widget.destinations,
              onDestinationSelected: (value) => setState(() => _selected = value),
              selectedIndex: _selected,
              labelType: widget.extended ? null : NavigationRailLabelType.all,
              backgroundColor: Colors.transparent,
              extended: widget.extended,
              minWidth: widget.minWidth,
              minExtendedWidth: widget.minExtendedWidth,
            ),
          ),
        ),
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title == null ? navRail : Column(children: [widget.title!, Expanded(child: navRail)]),
        Padding(
          padding: widget.dividerPadding ?? const EdgeInsets.all(0),
          child: const VerticalDivider(),
        ),
        Expanded(
          child: widget.contentBuilder(_selected),
        )
      ],
    );
  }
}
