import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../loaders/progress.dart';

typedef SearchProvider = StateProvider<String>;
typedef PaginatedListProvider<T> = StateNotifierProvider<PaginatedListDataNotifier<T>, DataPage<T>>;
typedef PaginatedListStream<T> = Stream<DataEvent<T>>;

class DataPage<T> {
  final int offset;
  final List<T> data;

  const DataPage({required this.offset, required this.data});
}

class DataDelta<T> {
  final bool Function(T element) from;
  final T to;

  DataDelta({required this.from, required this.to});
}

class DataEvent<T> {
  final DataDelta<T>? modify;
  final T? add;
  final bool Function(T element)? delete;

  DataEvent({this.delete, this.add, this.modify});

  factory DataEvent.modify(bool Function(T element) from, T to) => DataEvent(modify: DataDelta(from: from, to: to));

  factory DataEvent.add(T element) => DataEvent(add: element);

  factory DataEvent.delete(bool Function(T element) finder) => DataEvent(delete: finder);
}

class PaginatedListDataNotifier<T> extends StateNotifier<DataPage<T>> {
  final FutureOr<List<T>> Function(int offset, int limit, bool Function(T element)? filter) fetcher;
  final bool Function(T element)? filter;

  var _last = false;

  bool get last => _last;

  PaginatedListDataNotifier(this.fetcher, {this.filter}) : super(const DataPage(offset: -1, data: []));

  Future<void> fetch(int offset, int limit) async {
    final data = await fetcher(offset, limit, filter);
    if (mounted) {
      _last = data.length < limit;
      state = DataPage(offset: offset, data: data);
      return;
    }
  }
}

class PaginatedList<T> extends ConsumerStatefulWidget {
  final PaginatedListStream<T>? refreshStream;
  final PaginatedListProvider<T> dataProvider;
  final ItemWidgetBuilder<T> itemBuilder;
  final int limit;
  final ScrollController? scrollController;
  final Axis? scrollDirection;
  final void Function(List<T> items)? onChanged;
  final Widget? progressIndicator;
  final Widget? emptyIndicator;
  final Widget Function(dynamic error)? errorBuilder;
  final Key? listKey;

  const PaginatedList({
    super.key,
    required this.itemBuilder,
    required this.limit,
    required this.dataProvider,
    this.listKey,
    this.refreshStream,
    this.scrollController,
    this.scrollDirection,
    this.onChanged,
    this.progressIndicator,
    this.emptyIndicator,
    this.errorBuilder,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends ConsumerState<PaginatedList<T>> {
  final _controller = PagingController<int, T>(firstPageKey: 0);
  StreamSubscription? _refresher;

  @override
  void initState() {
    super.initState();
    _controller.removePageRequestListener(_fetch);
    _controller.addPageRequestListener(_fetch);
    _controller.addListener(_notify);
    ref.listenManual<DataPage<T>>(widget.dataProvider, _onDataUpdate);
    ref.listenManual<PaginatedListDataNotifier<T>>(widget.dataProvider.notifier, _onDataProviderUpdate);
    _refresher = widget.refreshStream?.listen(_onRefresh);
  }

  @override
  void dispose() {
    _controller.removePageRequestListener(_fetch);
    _controller.removeListener(_notify);
    _refresher?.cancel();
    super.dispose();
  }

  void _fetch(int page) {
    ref.read(widget.dataProvider.notifier).fetch(page, widget.limit).onError((error, stack) {
      if (mounted) {
        _controller.error = error;
        return;
      }
    });
  }

  void _onDataUpdate(DataPage<T>? previous, DataPage<T> next) {
    if (!mounted) return;
    final newItems = next.data;
    final isLastPage = newItems.length < widget.limit;
    if (isLastPage) {
      _controller.appendLastPage(newItems);
      return;
    }
    _controller.appendPage(newItems, next.offset + newItems.length);
  }

  void _onDataProviderUpdate(PaginatedListDataNotifier<T>? previous, PaginatedListDataNotifier<T> next) {
    if (!mounted) return;
    if (_controller.value.itemList?.isNotEmpty == true) {
      _controller.refresh();
      return;
    }
    _fetch(_controller.firstPageKey);
  }

  void _onRefresh(DataEvent<T> value) {
    if (!mounted) return;
    final filter = ref.read(widget.dataProvider.notifier).filter;
    var changed = false;
    final modified = [...(_controller.itemList ?? <T>[])];
    if (filter == null) {
      if (value.modify != null) {
        final existed = modified.indexWhere(value.modify!.from);
        if (existed != -1) {
          modified[existed] = value.modify!.to;
          changed = true;
        }
      }
      if (value.delete != null) {
        modified.removeWhere(value.modify!.from);
        changed = true;
      }
      if (value.add != null && ref.read(widget.dataProvider.notifier).last) {
        modified.add(value.add as T);
        changed = true;
      }
      if (changed) _controller.itemList = modified;
      return;
    }
    if (value.modify != null) {
      final existed = modified.indexWhere(value.modify!.from);
      if (existed != -1) {
        final permitted = filter(value.modify!.to);
        if (permitted) {
          modified[existed] = value.modify!.to;
        }
        if (!permitted) {
          modified.removeWhere(value.modify!.from);
        }
        changed = true;
      }
    }
    if (value.delete != null) {
      modified.removeWhere(value.modify!.from);
      changed = true;
    }
    if (value.add != null && ref.read(widget.dataProvider.notifier).last && filter(value.add as T)) {
      modified.add(value.add as T);
      changed = true;
    }
    if (changed) _controller.itemList = modified;
  }

  void _notify() {
    widget.onChanged?.call(_controller.itemList ?? []);
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, T>(
        key: widget.listKey,
        scrollDirection: widget.scrollDirection ?? Axis.vertical,
        scrollController: widget.scrollController ?? ScrollController(),
        builderDelegate: PagedChildBuilderDelegate<T>(
          noItemsFoundIndicatorBuilder: (context) => widget.emptyIndicator ?? Container(),
          noMoreItemsIndicatorBuilder: (context) => widget.emptyIndicator ?? Container(),
          firstPageProgressIndicatorBuilder: (context) => widget.progressIndicator ?? const Progress(),
          newPageProgressIndicatorBuilder: (context) => widget.progressIndicator ?? const Progress(),
          itemBuilder: widget.itemBuilder,
          firstPageErrorIndicatorBuilder: (context) => widget.errorBuilder?.call(_controller.error) ?? Container(),
          newPageErrorIndicatorBuilder: (context) => widget.errorBuilder?.call(_controller.error) ?? Container(),
          animateTransitions: false,
        ),
        pagingController: _controller,
      );
}
