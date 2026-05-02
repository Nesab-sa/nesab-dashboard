import 'package:flutter/material.dart';

/// Responsive 2- or 3-column row matching the HTML `.r2` / `.r3` classes.
/// Collapses to single column on narrow viewports.
class CalculatorGridRow extends StatelessWidget {
  const CalculatorGridRow({
    super.key,
    required this.children,
    this.spacing = 8,
    this.breakpoint = 500,
  });

  final List<Widget> children;
  final double spacing;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(children: children);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i < children.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}
