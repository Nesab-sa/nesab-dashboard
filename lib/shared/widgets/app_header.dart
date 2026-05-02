import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A reusable [AppBar]-style header that adapts to the current theme.
///
/// Optionally shows a back button that calls [context.pop()] from GoRouter.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    required this.title,
    this.showBackButton = true,
    this.actions,
    super.key,
  });

  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            )
          : null,
      title: Text(title, style: theme.textTheme.titleMedium),
      actions: actions,
    );
  }
}
