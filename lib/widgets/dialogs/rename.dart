import 'dart:async';

import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';

class RenameDialog extends StatefulWidget {
  final String title;
  final String name;
  final FutureOr<void> Function(String newName) onRename;
  final String? Function(String newName)? validate;
  final String renameButtonText;
  final String cancelButtonText;

  const RenameDialog({
    super.key,
    required this.title,
    required this.name,
    required this.onRename,
    this.validate,
    required this.renameButtonText,
    required this.cancelButtonText,
  });

  static void show(BuildContext context, RenameDialog dialog) => showDialog(context: context, builder: (_) => dialog);

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late String _name;
  late String? _error;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _controller = TextEditingController(text: _name);
    _error = null;
  }

  @override
  void dispose() {
    _name = widget.name;
    _error = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Spacings.medium),
          child: FilledButton(
            onPressed: _error == null ? _save : null,
            child: Text(widget.renameButtonText),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: Spacings.medium),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.cancelButtonText),
          ),
        ),
      ],
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
        ],
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: (_) => _validate(),
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          errorText: _error,
          prefixIcon: const Icon(Icons.edit),
        ),
      ),
    );
  }

  void _save() {
    if (!_validate()) return;
    final newName = _controller.text;
    Future.value(widget.onRename(newName)).then((value) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  bool _validate() {
    final newName = _controller.text;
    final newError = widget.validate?.call(newName);
    setState(() => _error = newError);
    return newError == null;
  }
}
