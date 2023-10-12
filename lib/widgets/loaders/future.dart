import 'package:flutter/material.dart';

class FutureLoader<T> extends StatefulWidget {
  final Future<T>? future;
  final Future<T> Function()? provider;
  final Widget loader;
  final Widget Function(BuildContext context, T data, void Function() invalidate) content;
  final Widget Function(dynamic error)? error;

  const FutureLoader({
    super.key,
    required this.loader,
    required this.content,
    required this.error,
    this.future,
    this.provider,
  });

  @override
  State<FutureLoader<T>> createState() => _FutureLoaderState<T>();
}

class _FutureLoaderState<T> extends State<FutureLoader<T>> {
  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: widget.provider == null ? widget.future : widget.provider!(),
        builder: (context, state) => state.hasError
            ? widget.error?.call(state.error) ?? widget.loader
            : state.hasData
                ? widget.content(context, state.requireData, () => setState(() => {}))
                : widget.loader,
      );
}
