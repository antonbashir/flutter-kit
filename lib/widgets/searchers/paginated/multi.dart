import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/sizes.dart';
import '../../views/list.dart';

class PaginatedMultiSearch extends ConsumerStatefulWidget {
  final String label;
  final double? width;
  final double suggestionsHeight;
  final Set<String> initialSelected;
  final Widget Function(BuildContext context, String item)? suggestionLeading;
  final double? elevation;
  final ValueChanged<String>? onAdd;
  final ValueChanged<String>? onDelete;
  final VoidCallback? onClear;
  final int pageSize;
  final void Function(String value) onSearch;
  final PaginatedListProvider<String> dataProvider;
  final PaginatedListRefresher<String>? refreshProvider;
  final bool enabled;
  final Widget Function(dynamic error)? errorBuilder;
  final Widget? searchFieldLeading;
  final bool cached;

  const PaginatedMultiSearch({
    super.key,
    required this.label,
    required this.pageSize,
    required this.onSearch,
    required this.dataProvider,
    required this.suggestionsHeight,
    required this.initialSelected,
    this.width,
    this.onAdd,
    this.refreshProvider,
    this.onDelete,
    this.suggestionLeading,
    this.elevation,
    this.onClear,
    this.errorBuilder,
    this.enabled = true,
    this.cached = true,
    this.searchFieldLeading,
  });

  @override
  ConsumerState<PaginatedMultiSearch> createState() => _PaginatedCheckboxSearchState();
}

class _PaginatedCheckboxSearchState extends ConsumerState<PaginatedMultiSearch> {
  late final SearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SearchController();
    _controller.addListener(_search);
  }

  @override
  void dispose() {
    _controller.removeListener(_search);
    super.dispose();
  }

  void _search() {
    widget.onSearch(_controller.text);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.width,
        child: SearchAnchor(
          searchController: _controller,
          viewConstraints: BoxConstraints.tightFor(height: widget.suggestionsHeight),
          builder: (BuildContext context, SearchController controller) => SearchBar(
            elevation: widget.elevation == null ? null : MaterialStatePropertyAll(widget.elevation),
            controller: controller,
            hintText: widget.label,
            onTap: widget.enabled ? () => controller.openView() : null,
            onChanged: widget.enabled ? (_) => controller.openView() : null,
            leading: widget.searchFieldLeading ?? const Icon(Icons.search),
            trailing: [
              if (widget.onClear != null)
                IconButton(
                  onPressed: widget.onClear!,
                  icon: const Icon(Icons.cancel),
                )
            ],
          ),
          viewBuilder: (suggestions) => suggestions.isEmpty ? Container() : suggestions.first,
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            if (!widget.cached) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (mounted) {
                  ref.invalidate(widget.dataProvider);
                  if (widget.refreshProvider != null) ref.invalidate(widget.refreshProvider!);
                }
              });
            }
            if (!mounted) return [];
            return [
              SizedBox(
                height: widget.suggestionsHeight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Spacings.medium),
                  child: PaginatedList<String>(
                    errorBuilder: widget.errorBuilder,
                    itemBuilder: (context, item, index) {
                      var selected = widget.initialSelected.contains(item);
                      return StatefulBuilder(
                        builder: (context, setState) => CheckboxListTile(
                          value: selected,
                          onChanged: (value) {
                            if (value == true) {
                              setState(() => selected = true);
                              widget.onAdd?.call(item);
                              return;
                            }
                            setState(() => selected = false);
                            widget.onDelete?.call(item);
                          },
                          title: widget.suggestionLeading == null
                              ? Text(item)
                              : Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(Spacings.small),
                                      child: widget.suggestionLeading!.call(context, item),
                                    ),
                                    Text(item)
                                  ],
                                ),
                        ),
                      );
                    },
                    pageSize: widget.pageSize,
                    dataProvider: widget.dataProvider,
                    refreshProvider: widget.refreshProvider,
                  ),
                ),
              )
            ];
          },
        ),
      );
}
