import 'package:flutter/material.dart';
import 'package:vstackweb/theme/responsive.dart';

class ToolSplitLayout extends StatelessWidget {
  const ToolSplitLayout({
    super.key,
    required this.input,
    required this.preview,
    this.previewFlex = 1,
    this.inputFlex = 1,
  });

  final Widget input;
  final Widget preview;
  final int previewFlex;
  final int inputFlex;

  @override
  Widget build(BuildContext context) {
    final wide = AppLayout.isDesktop(context) || MediaQuery.sizeOf(context).width >= 900;
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          input,
          const SizedBox(height: 20),
          preview,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: inputFlex, child: input),
        const SizedBox(width: 24),
        Expanded(flex: previewFlex, child: preview),
      ],
    );
  }
}
