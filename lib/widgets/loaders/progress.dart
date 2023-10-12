import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';

class Progress extends StatelessWidget {
  const Progress({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(strokeWidth: Sizes.progressStrokeWidth),
      );
}
