import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';

class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final void Function() onDelete;
  final String deleteButtonText;
  final String cancelButtonText;

  const DeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDelete,
    required this.deleteButtonText,
    required this.cancelButtonText,
  });

  static void show(BuildContext context, DeleteDialog dialog) => showDialog(context: context, builder: (_) => dialog);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Spacings.medium),
          child: FilledButton(
              style: theme.filledButtonTheme.style?.copyWith(
                foregroundColor: MaterialStatePropertyAll(theme.colorScheme.onError),
                backgroundColor: MaterialStatePropertyAll(theme.colorScheme.error),
              ),
              onPressed: () {
                onDelete.call();
                Navigator.pop(context);
              },
              child: Text(deleteButtonText)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: Spacings.medium),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelButtonText),
          ),
        ),
      ],
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
        ],
      ),
      content: Text(message),
    );
  }
}
