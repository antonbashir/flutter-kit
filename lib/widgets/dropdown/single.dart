import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/sizes.dart';
import '../../../theme/common.dart';
import '../views/list.dart';

class PaginatedSingleDropdown<T> extends ConsumerStatefulWidget {
  final String label;
  final double? width;
  final double suggestionsHeight;
  final Icon? suggestionLeading;
  final double? elevation;
  final ValueChanged<T>? onSubmit;
  final VoidCallback? onClear;
  final int limit;
  final void Function(String value) onSearch;
  final PaginatedListProvider<T> dataProvider;
  final PaginatedListStream<T>? refreshStream;
  final bool insertSelectedText;
  final Widget? fieldPrefix;
  final Widget Function(BuildContext context, T item)? itemPrefix;
  final bool enabled;
  final Widget Function(dynamic error)? errorBuilder;
  final bool cached;
  final T? initialSelected;
  final String Function(T item) itemFieldBuilder;

  const PaginatedSingleDropdown({
    super.key,
    required this.label,
    required this.limit,
    required this.onSearch,
    required this.dataProvider,
    required this.suggestionsHeight,
    required this.itemFieldBuilder,
    this.insertSelectedText = false,
    this.width,
    this.onSubmit,
    this.refreshStream,
    this.suggestionLeading,
    this.elevation,
    this.onClear,
    this.fieldPrefix,
    this.itemPrefix,
    this.enabled = true,
    this.cached = true,
    this.errorBuilder,
    this.initialSelected,
  });

  @override
  ConsumerState<PaginatedSingleDropdown<T>> createState() => _PaginatedSingleDropdownState<T>();
}

class _PaginatedSingleDropdownState<T> extends ConsumerState<PaginatedSingleDropdown<T>> {
  late final SearchController _searchController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _textController = TextEditingController();
    _searchController.addListener(_search);
    if (widget.initialSelected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchController.text = widget.itemFieldBuilder(widget.initialSelected as T);
        _textController.text = widget.itemFieldBuilder(widget.initialSelected as T);
        widget.onSubmit?.call(widget.initialSelected as T);
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_search);
    super.dispose();
  }

  void _search() {
    widget.onSearch(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final search = SizedBox(
      width: widget.width,
      child: SearchAnchor(
        searchController: _searchController,
        viewConstraints: BoxConstraints.tightFor(height: widget.suggestionsHeight),
        builder: (BuildContext context, SearchController controller) => SearchBar(
          elevation: MaterialStatePropertyAll(widget.elevation),
          shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          shadowColor: const MaterialStatePropertyAll(Colors.transparent),
          controller: _textController,
          hintText: widget.label,
          onTap: widget.enabled
              ? () {
                  controller.text = _textController.text;
                  controller.openView();
                }
              : null,
          onChanged: widget.enabled
              ? (_) {
                  controller.text = _textController.text;
                  controller.openView();
                }
              : null,
          leading: widget.fieldPrefix ?? const Icon(Icons.search),
          trailing: [
            if (widget.onClear != null)
              IconButton(
                onPressed: widget.onClear!,
                icon: const Icon(Icons.cancel),
              )
          ],
        ),
        viewBuilder: (suggestions) => suggestions.isEmpty ? Container() : suggestions.first,
        viewShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        viewTrailing: const [],
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          if (!widget.cached) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (mounted) {
                ref.invalidate(widget.dataProvider);
              }
            });
          }
          if (!mounted) return [];
          return [
            SizedBox(
              height: widget.suggestionsHeight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: Spacings.medium),
                child: PaginatedList<T>(
                  errorBuilder: widget.errorBuilder,
                  itemBuilder: (context, item, index) => ListTile(
                    leading: widget.itemPrefix?.call(context, item),
                    onTap: () {
                      widget.onSubmit?.call(item);
                      if (widget.insertSelectedText) {
                        _textController.text = widget.itemFieldBuilder(item);
                        _searchController.text = widget.itemFieldBuilder(item);
                      }
                      controller.closeView(null);
                    },
                    title: widget.suggestionLeading == null
                        ? Text(widget.itemFieldBuilder(item))
                        : Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(Spacings.small),
                                child: widget.suggestionLeading!,
                              ),
                              Text(widget.itemFieldBuilder(item))
                            ],
                          ),
                  ),
                  limit: widget.limit,
                  dataProvider: widget.dataProvider,
                  refreshStream: widget.refreshStream,
                ),
              ),
            )
          ];
        },
      ),
    );
    return widget.enabled
        ? search
        : Opacity(
            opacity: CommonThemeColors.disabledOpacity,
            child: IgnorePointer(child: search),
          );
  }
}
