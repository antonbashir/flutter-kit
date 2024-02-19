import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/size_response_provider.dart';

class SizeObserverHelper extends StatefulWidget {
  const SizeObserverHelper(
      {required this.child, required this.devicePixelRatio, Key? key})
      : super(key: key);

  final Widget child;
  final double devicePixelRatio;

  @override
  State<SizeObserverHelper> createState() => _SizeObserverHelperState();
}

class _SizeObserverHelperState extends State<SizeObserverHelper>
    with WidgetsBindingObserver {
  late Size _lastSize;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _lastSize = View.of(context).physicalSize;
    WidgetsBinding.instance.addObserver(this);
    context
        .read<SizeResponseProvider>()
        .init(_lastSize.width, widget.devicePixelRatio);
    super.didChangeDependencies();
  }

  @override
  void didChangeMetrics() {
    _lastSize = View.of(context).physicalSize;
    context.read<SizeResponseProvider>().onScreenWidthChange(
        _lastSize.width, MediaQuery.of(context).devicePixelRatio);
  }

  @override
  void didChangeTextScaleFactor() {
    _lastSize = View.of(context).physicalSize;
    context.read<SizeResponseProvider>().onScreenWidthChange(
        _lastSize.width, MediaQuery.of(context).devicePixelRatio);
    super.didChangeTextScaleFactor();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class SizeObserver extends StatefulWidget {
  const SizeObserver({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<SizeObserver> createState() => _SizeObserverState();
}

class _SizeObserverState extends State<SizeObserver> {
  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return SizeObserverHelper(
        devicePixelRatio: pixelRatio, child: widget.child);
  }
}
