import 'package:flutter/material.dart';
import 'package:flutter_kit/theme/common.dart';

import '../../../../constants/sizes.dart';

class MultiSearch extends StatelessWidget {
  final String label;
  final double width;
  final double suggestionsHeight;
  final Set<String> available;
  final Set<String> initialSelected;
  final Widget Function(BuildContext context, String item)? suggestionLeading;
  final ValueChanged<String>? onAdd;
  final ValueChanged<String>? onDelete;
  final VoidCallback? onClear;
  final List<String> Function(String input) searcher;
  final double? elevation;
  final bool enabled;
  final Widget? searchFieldLeading;

  const MultiSearch({
    super.key,
    required this.label,
    required this.searcher,
    required this.width,
    required this.suggestionsHeight,
    required this.available,
    required this.initialSelected,
    this.onAdd,
    this.onDelete,
    this.suggestionLeading,
    this.onClear,
    this.elevation,
    this.searchFieldLeading,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final search = SizedBox(
      width: width,
      child: SearchAnchor(
        viewConstraints: BoxConstraints.tightFor(height: suggestionsHeight),
        builder: (BuildContext context, SearchController controller) => SearchBar(
          controller: controller,
          hintText: label,
          elevation: elevation == null ? null : MaterialStatePropertyAll(elevation),
          onTap: enabled ? () => controller.openView() : null,
          onChanged: enabled ? (_) => controller.openView() : null,
          leading: searchFieldLeading ?? const Icon(Icons.search),
          trailing: [
            if (onClear != null)
              IconButton(
                onPressed: onClear!,
                icon: const Icon(Icons.cancel),
              )
          ],
        ),
        suggestionsBuilder: (BuildContext context, SearchController controller) => searcher(controller.text)
            .map(
              (option) => _Item(
                selected: initialSelected.contains(option),
                option: option,
                onAdd: onAdd,
                onClear: onClear,
                onDelete: onDelete,
                suggestionLeading: suggestionLeading,
              ),
            )
            .toList(),
      ),
    );
    return enabled
        ? search
        : Opacity(
            opacity: CommonThemeColors.disabledOpacity,
            child: IgnorePointer(
              child: search,
            ),
          );
  }
}

class _Item extends StatefulWidget {
  final bool selected;
  final Widget Function(BuildContext context, String item)? suggestionLeading;
  final ValueChanged<String>? onAdd;
  final ValueChanged<String>? onDelete;
  final VoidCallback? onClear;
  final String option;

  const _Item({
    required this.selected,
    required this.option,
    this.suggestionLeading,
    this.onAdd,
    this.onDelete,
    this.onClear,
  });

  @override
  State<StatefulWidget> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  late bool _selected = widget.selected;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
        value: _selected,
        onChanged: (value) {
          if (value == true) {
            setState(() => _selected = true);
            widget.onAdd?.call(widget.option);
            return;
          }
          setState(() => _selected = false);
          widget.onDelete?.call(widget.option);
        },
        title: widget.suggestionLeading == null
            ? Text(widget.option)
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Spacings.small),
                    child: widget.suggestionLeading!.call(context, widget.option),
                  ),
                  Text(widget.option)
                ],
              ),
      );
}
