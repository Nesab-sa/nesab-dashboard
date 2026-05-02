import 'package:flutter/material.dart';

/// A centered [CircularProgressIndicator] that uses the theme's primary color
/// unless overridden via [color].
class AppLoading extends StatelessWidget {
  const AppLoading({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
