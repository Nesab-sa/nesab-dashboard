import 'package:flutter/material.dart';
import 'package:nesab/shared/widgets/gradiant_widget.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({
    required this.child,
    this.bottomNavigationBar,
    super.key,
  });

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        const Positioned(child: GradiantWidget(width: double.infinity)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: child),
          bottomNavigationBar: bottomNavigationBar,
        ),
      ],
    );
  }
}
