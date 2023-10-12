import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../constants/sizes.dart';
import '../../../../../extensions/extensions.dart';
import '../../../searchers/paginated/multi.dart';
import '../../../views/list.dart';

class PaginatedTagCheckboxesFilter extends ConsumerStatefulWidget {
  final String label;
  final double width;
  final double suggestionsHeight;
  final Set<String> selected;
  final Widget Function(BuildContext context, String item)? suggestionLeading;
  final double? elevation;
  final ValueChanged<Set<String>>? onChanged;
  final int pageSize;
  final PaginatedListProvider<String> dataProvider;
  final PaginatedListRefresher<String>? refreshProvider;
  final void Function(String search) onSearch;
  final Widget Function(dynamic error)? errorBuilder;

  const PaginatedTagCheckboxesFilter({
    super.key,
    required this.label,
    required this.width,
    required this.suggestionsHeight,
    required this.selected,
    required this.pageSize,
    required this.dataProvider,
    required this.onSearch,
    this.refreshProvider,
    this.onChanged,
    this.suggestionLeading,
    this.elevation,
    this.errorBuilder,
  });

  @override
  ConsumerState<PaginatedTagCheckboxesFilter> createState() => _TagFilterState();
}

class _TagFilterState extends ConsumerState<PaginatedTagCheckboxesFilter> {
  var selected = <String>{};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selected = {...widget.selected};
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PaginatedMultiSearch(
            errorBuilder: widget.errorBuilder,
            label: widget.label,
            dataProvider: widget.dataProvider,
            initialSelected: selected,
            pageSize: widget.pageSize,
            onSearch: widget.onSearch,
            refreshProvider: widget.refreshProvider,
            suggestionsHeight: widget.suggestionsHeight,
            suggestionLeading: widget.suggestionLeading,
            elevation: widget.elevation,
            width: widget.width,
            onClear: () {
              setState(() => selected = {});
              widget.onChanged?.call(selected);
            },
            onAdd: (option) {
              setState(() => selected = {...widget.selected, option});
              widget.onChanged?.call(selected);
            },
            onDelete: (option) {
              setState(() => selected = widget.selected.without(option));
              widget.onChanged?.call(selected);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: Spacings.medium),
            child: SizedBox(
              width: widget.width,
              child: Wrap(
                spacing: Spacings.medium,
                runSpacing: Spacings.medium,
                children: widget.selected
                    .map(
                      (value) => Chip(
                        label: Text(value),
                        onDeleted: () {
                          setState(() => selected = widget.selected.without(value));
                          widget.onChanged?.call(selected);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          )
        ],
      );
}
