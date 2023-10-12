import 'package:flutter/material.dart';

import '../../../../../constants/sizes.dart';
import '../../../../../extensions/extensions.dart';
import '../../../searchers/simple/multi.dart';

class TagCheckboxesFilter extends StatefulWidget {
  final String label;
  final double width;
  final double suggestionsHeight;
  final Set<String> available;
  final Set<String> selected;
  final Widget Function(BuildContext context, String item)? suggestionLeading;
  final ValueChanged<Set<String>>? onChanged;
  final double? elevation;

  const TagCheckboxesFilter({
    super.key,
    required this.label,
    required this.width,
    required this.suggestionsHeight,
    required this.available,
    required this.selected,
    this.onChanged,
    this.suggestionLeading,
    this.elevation,
  });

  @override
  State<TagCheckboxesFilter> createState() => _TagCheckboxesFilterState();
}

class _TagCheckboxesFilterState extends State<TagCheckboxesFilter> {
  var _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selected};
  }

  @override
  void dispose() {
    _selected = {};
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MultiSearch(
            label: widget.label,
            available: widget.available,
            elevation: widget.elevation,
            initialSelected: _selected,
            searcher: _search,
            suggestionsHeight: widget.suggestionsHeight,
            suggestionLeading: widget.suggestionLeading,
            width: widget.width,
            onClear: () {
              setState(() => _selected = {});
              widget.onChanged?.call(_selected);
            },
            onAdd: (option) {
              setState(() => _selected = {...widget.selected, option});
              widget.onChanged?.call(_selected);
            },
            onDelete: (option) {
              setState(() => _selected = widget.selected.without(option));
              widget.onChanged?.call(_selected);
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
                          setState(() => _selected = widget.selected.without(value));
                          widget.onChanged?.call(_selected);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          )
        ],
      );

  List<String> _search(String query) {
    if (query.isNotEmpty) {
      var lowercaseQuery = query.toLowerCase();
      final results = widget.available.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList(growable: false);
      results.sort((left, right) => left.toLowerCase().indexOf(lowercaseQuery).compareTo(right.toLowerCase().indexOf(lowercaseQuery)));
      return results;
    }
    return widget.available.toList();
  }
}
