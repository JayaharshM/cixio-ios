import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../features/chat/providers/chat_provider.dart';
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
    final AppColors c = AppColors.of(context);
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

    bool hideNavBar = false;
    if (routeIndex == 0) {
      final chatState = ref.watch(chatProvider);
      hideNavBar = chatState.activeSession != null;
    }

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      body: child,
      bottomNavigationBar: hideNavBar ? null : const FloatingGlassNavBar(),
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
