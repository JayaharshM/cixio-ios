import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/tab_navigation_provider.dart';
import '../../shared/widgets/floating_glass_nav_bar.dart';

class AppTabShell extends ConsumerWidget {
  const AppTabShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String path = GoRouterState.of(context).uri.path;
    final int routeIndex = _indexForPath(path);
    final int selectedIndex = ref.watch(selectedTabIndexProvider);

    if (routeIndex != selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ref.read(selectedTabIndexProvider.notifier).state = routeIndex;
        }
      });
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: const FloatingGlassNavBar(),
    );
  }

  int _indexForPath(String path) {
    return switch (path) {
      '/docs' => 1,
      '/todos' => 2,
      '/profile' => 3,
      _ => 0,
    };
  }
}
