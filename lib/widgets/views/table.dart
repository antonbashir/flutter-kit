import 'dart:math';

import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';
import '../../../extensions/extensions.dart';
import '../extensions/expansion_tile.dart';
import '../loaders/progress.dart';
import 'list.dart';

class PaginatedTable<T> extends StatefulWidget {
  final List<TableViewHeader> headers;
  final double headerHeight;
  final double rowDividerHeight;
  final double headerDividerHeight;
  final Color? headerBackgroundColor;
  final Color? headerDividerColor;
  final Color? rowDividerColor;
  final TableViewRow Function(BuildContext context, T item, int index) rowBuilder;
  final TableViewExpansion Function(BuildContext context, T item, int index)? expansionBuilder;
  final double Function(BuildContext context, T item, int index)? rowHeightCalculator;
  final double rowHeight;
  final PaginatedListRefresher<T>? refreshProvider;
  final PaginatedListProvider<T> dataProvider;
  final Widget Function(dynamic error)? errorBuilder;
  final TableViewRow Function(BuildContext context, TableViewRow current)? rowBuildDecorator;
  final int pageSize;
  final double horizontalScrollViewPadding;
  final double loaderPadding;
  final bool autoSize;
  final double headerMinWidthSum;

  PaginatedTable({
    super.key,
    required this.headers,
    required this.rowBuilder,
    required this.dataProvider,
    required this.pageSize,
    this.expansionBuilder,
    this.rowHeight = 100,
    this.headerHeight = 40,
    this.rowDividerHeight = 1.0,
    this.headerDividerHeight = 1.0,
    this.horizontalScrollViewPadding = Spacings.medium,
    this.loaderPadding = Spacings.small,
    this.refreshProvider,
    this.rowHeightCalculator,
    this.headerDividerColor,
    this.rowDividerColor,
    this.headerBackgroundColor,
    this.errorBuilder,
    this.rowBuildDecorator,
    this.autoSize = true,
  }) : headerMinWidthSum = headers.map((header) => header.minWidth).reduce((value, element) => value + element);

  @override
  State<PaginatedTable> createState() => _PaginatedTableState<T>();
}

class _PaginatedTableState<T> extends State<PaginatedTable<T>> {
  late final _listKey = GlobalKey();

  final _horizontalScrollController = ScrollController();
  final _realVerticalScrollController = ScrollController();
  final _fakeVerticalScrollController = ScrollController();

  var _updatingRealController = false;
  var _updatingFakeController = false;

  var _fakeScrollHeight = 1.0;

  void _updateRealVerticalPosition() {
    if (_updatingFakeController) return;
    _updatingRealController = true;
    _realVerticalScrollController.jumpTo(_fakeVerticalScrollController.position.pixels);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatingRealController = false);
  }

  void _updateFakeVerticalPosition() {
    if (_updatingRealController) return;
    _updatingFakeController = true;
    _fakeVerticalScrollController.jumpTo(_realVerticalScrollController.position.pixels);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatingFakeController = false);
  }

  @override
  void initState() {
    super.initState();
    _realVerticalScrollController.addListener(_updateFakeVerticalPosition);
    _fakeVerticalScrollController.addListener(_updateRealVerticalPosition);
  }

  @override
  void dispose() {
    _realVerticalScrollController.removeListener(_updateFakeVerticalPosition);
    _fakeVerticalScrollController.removeListener(_updateRealVerticalPosition);
    _horizontalScrollController.dispose();
    _realVerticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thickness = theme.scrollbarTheme.thickness?.resolve({MaterialState.hovered}) ?? (theme.platform == TargetPlatform.android || theme.platform == TargetPlatform.iOS ? 4 : 8);
    final padding = thickness / widget.headers.length + 1;
    return Padding(
      padding: EdgeInsets.only(left: thickness),
      child: LayoutBuilder(builder: (context, constraints) {
        final headerViews = widget.headers
            .map(
              (header) => _HeaderView(
                header: header,
                width: max(header.minWidth, header.width ?? (widget.autoSize ? constraints.maxWidth * header.minWidth / widget.headerMinWidthSum : header.minWidth)) - padding,
              ),
            )
            .toList();
        final contentWidth = headerViews.map((header) => header.width).reduce((value, element) => value + element);
        return Row(
          children: [
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _horizontalScrollController,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(vertical: widget.horizontalScrollViewPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            color: widget.headerBackgroundColor,
                            height: widget.headerHeight,
                            child: Row(children: headerViews),
                          ),
                          Container(
                            height: widget.headerDividerHeight,
                            width: contentWidth,
                            color: widget.headerDividerColor ?? theme.dividerColor,
                          )
                        ],
                      ),
                      Expanded(
                        child: SizedBox(
                          width: contentWidth,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: PaginatedList<T>(
                              listKey: _listKey,
                              progressIndicator: Padding(padding: EdgeInsets.all(widget.loaderPadding), child: const Progress()),
                              scrollController: _realVerticalScrollController,
                              itemBuilder: (context, item, index) {
                                final sourceExpansion = widget.expansionBuilder?.call(context, item, index);
                                final effectiveExpansion = sourceExpansion == null
                                    ? null
                                    : TableViewExpansion(
                                        child: sourceExpansion.child,
                                        onChanged: (value) {
                                          setState(() {
                                            _fakeScrollHeight = value ? _fakeScrollHeight + sourceExpansion.height : _fakeScrollHeight - sourceExpansion.height;
                                          });
                                          sourceExpansion.onChanged?.call(value);
                                        },
                                        height: sourceExpansion.height,
                                      );
                                return _RowView(
                                  buildDecorator: widget.rowBuildDecorator,
                                  row: widget.rowBuilder(context, item, index),
                                  owner: widget,
                                  rowWidth: contentWidth,
                                  cellWidths: headerViews.map((header) => header.width).toList(),
                                  rowHeight: widget.rowHeightCalculator?.call(context, item, index) ?? widget.rowHeight,
                                  expansion: effectiveExpansion,
                                );
                              },
                              pageSize: widget.pageSize,
                              dataProvider: widget.dataProvider,
                              refreshProvider: widget.refreshProvider,
                              errorBuilder: widget.errorBuilder,
                              onChanged: (items) {
                                if (widget.rowHeightCalculator == null) {
                                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                    setState(() {
                                      _fakeScrollHeight = items.length * (widget.rowHeight + widget.rowDividerHeight);
                                    });
                                  });
                                  return;
                                }
                                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                  setState(() {
                                    _fakeScrollHeight = items
                                        .mapIndexed(
                                          (index, element) => widget.rowHeightCalculator!(context, element, index) + widget.rowDividerHeight,
                                        )
                                        .reduce(
                                          (value, element) => value + element,
                                        );
                                  });
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: thickness,
              height: double.infinity,
              padding: EdgeInsets.only(top: widget.headerHeight + (widget.horizontalScrollViewPadding * 2) + widget.headerDividerHeight),
              child: Align(
                alignment: Alignment.topCenter,
                child: Scrollbar(
                  controller: _fakeVerticalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _fakeVerticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: thickness,
                      height: _fakeScrollHeight + Sizes.progressIndicatorDefaultSize + widget.loaderPadding * 2,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}

class TableViewHeader {
  final Widget label;
  final double minWidth;
  final AlignmentGeometry alignment;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const TableViewHeader({
    required this.minWidth,
    required this.label,
    this.alignment = Alignment.center,
    this.width,
    this.padding,
  });
}

class _HeaderView extends StatelessWidget {
  final TableViewHeader header;
  final double width;

  const _HeaderView({required this.header, required this.width});

  @override
  Widget build(BuildContext context) => Container(
        padding: header.padding,
        width: width,
        child: Align(alignment: header.alignment, child: header.label),
      );
}

class TableViewExpansion {
  final Widget child;
  final double height;
  final ValueChanged<bool>? onChanged;

  TableViewExpansion({required this.child, required this.height, this.onChanged});
}

class TableViewRow {
  final List<TableViewCell> cells;
  final Color? backgroundColor;
  final void Function()? onTap;
  final void Function()? onTertiaryTap;

  TableViewRow({required this.cells, this.backgroundColor, this.onTap, this.onTertiaryTap});

  TableViewRow copyWith({List<TableViewCell>? cells, Color? backgroundColor, void Function()? onTap}) => TableViewRow(
        cells: cells ?? this.cells,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        onTap: onTap ?? this.onTap,
      );

  TableViewRow disable() => TableViewRow(
        cells: cells,
        backgroundColor: backgroundColor,
        onTap: null,
      );
}

class TableViewCell extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  const TableViewCell({
    super.key,
    this.alignment = Alignment.center,
    this.padding = EdgeInsets.zero,
    this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(padding: padding, child: Align(alignment: alignment, child: child));
}

class _RowView extends StatelessWidget {
  final PaginatedTable owner;
  final TableViewRow row;
  final TableViewExpansion? expansion;
  final double rowHeight;
  final double rowWidth;
  final List<double> cellWidths;
  final TableViewRow Function(BuildContext context, TableViewRow current)? buildDecorator;

  const _RowView({
    required this.row,
    required this.owner,
    required this.rowHeight,
    required this.rowWidth,
    required this.cellWidths,
    required this.buildDecorator,
    this.expansion,
  });

  @override
  Widget build(BuildContext context) {
    final row = buildDecorator?.call(context, this.row) ?? this.row;
    final theme = Theme.of(context);
    Widget rowWidget = Container(
      color: row.backgroundColor,
      height: rowHeight,
      child: Row(
        children: row.cells.mapIndexed(
          (index, cell) => SizedBox(
            width: cellWidths[index],
            child: cell,
          ),
        ),
      ),
    );
    return GestureDetector(
      onTertiaryTapUp: (_) => row.onTertiaryTap?.call(),
      child: InkWell(
        onTap: row.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            expansion != null
                ? SizedBox(
                    width: rowWidth,
                    child: CustomExpansionTile(
                      onExpansionChanged: expansion!.onChanged,
                      row: rowWidget,
                      children: [SizedBox(height: expansion!.height, child: expansion!.child)],
                    ),
                  )
                : rowWidget,
            Container(
              height: owner.rowDividerHeight,
              width: rowWidth,
              color: owner.rowDividerColor ?? theme.dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}
