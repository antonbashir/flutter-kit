import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/sizes.dart';
import '../../../../extensions/extensions.dart';
import '../../../../theme/common.dart';
import '../../views/list.dart';

class PaginatedSingleSearch extends ConsumerStatefulWidget {
  final String label;
  final double? width;
  final double suggestionsHeight;
  final double? elevation;
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onClear;
  final int limit;
  final void Function(String value) onSearch;
  final PaginatedListProvider<String> dataProvider;
  final PaginatedListStream<String>? refreshStream;
  final bool insertSelectedText;
  final Widget? searchFieldLeading;
  final Widget Function(BuildContext context, String item)? itemTileLeading;
  final Widget Function(BuildContext context, String item)? suggestionLeading;
  final bool enabled;
  final Widget Function(dynamic error)? errorBuilder;
  final bool cached;
  final String? initialSelected;
  final String Function(String item)? itemDecorator;

  const PaginatedSingleSearch({
    super.key,
    required this.label,
    required this.limit,
    required this.onSearch,
    required this.dataProvider,
    required this.suggestionsHeight,
    this.insertSelectedText = false,
    this.width,
    this.onSubmit,
    this.refreshStream,
    this.suggestionLeading,
    this.elevation,
    this.onClear,
    this.searchFieldLeading,
    this.itemTileLeading,
    this.enabled = true,
    this.cached = true,
    this.errorBuilder,
    this.initialSelected,
    this.itemDecorator,
  });

  @override
  ConsumerState<PaginatedSingleSearch> createState() => _PaginatedSingleSearchState();
}

class _PaginatedSingleSearchState extends ConsumerState<PaginatedSingleSearch> {
  late final SearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SearchController();
    _controller.addListener(_search);
    if (widget.initialSelected.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.itemDecorator == null ? widget.initialSelected! : widget.itemDecorator!(widget.initialSelected!);
        widget.onSubmit?.call(widget.initialSelected!);
      });
    }
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
  Widget build(BuildContext context) {
    final search = SizedBox(
      width: widget.width,
      child: SearchAnchor(
        searchController: _controller,
        viewConstraints: BoxConstraints.tightFor(height: widget.suggestionsHeight),
        builder: (BuildContext context, SearchController controller) => SearchBar(
          elevation: MaterialStatePropertyAll(widget.elevation),
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
                  itemBuilder: (context, item, index) => ListTile(
                    leading: widget.itemTileLeading?.call(context, item),
                    onTap: () {
                      widget.onSubmit?.call(item);
                      controller.closeView(
                        widget.insertSelectedText
                            ? widget.itemDecorator == null
                                ? item
                                : widget.itemDecorator!(item)
                            : null,
                      );
                    },
                    title: widget.suggestionLeading == null
                        ? Text(widget.itemDecorator == null ? item : widget.itemDecorator!(item))
                        : Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(Spacings.small),
                                child: widget.suggestionLeading!(context, item),
                              ),
                              Text(widget.itemDecorator == null ? item : widget.itemDecorator!(item))
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
            child: IgnorePointer(
              child: search,
            ),
          );
  }
}
