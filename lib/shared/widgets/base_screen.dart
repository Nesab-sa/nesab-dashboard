import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background gradient
            //   const Positioned(child: GradiantWidget()),
            // Main content
            SizedBox.expand(
              child: Scaffold(backgroundColor: Colors.transparent, body: child),
            ),
          ],
        ),
      ),
    );
  }
}
