import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../providers/tab_navigation_provider.dart';

class FloatingGlassNavBar extends ConsumerWidget {
  const FloatingGlassNavBar({super.key});

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(
      label: 'Chat',
      icon: Icons.chat_bubble_outline_rounded,
      route: AppRoute.chat,
    ),
    _NavItem(
      label: 'Docs',
      icon: Icons.description_outlined,
      route: AppRoute.docs,
    ),
    _NavItem(
      label: 'Todos',
      icon: Icons.check_circle_outline_rounded,
      route: AppRoute.todos,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.account_circle_outlined,
      route: AppRoute.profile,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int selectedIndex = ref.watch(selectedTabIndexProvider);
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double safeBottomPadding = bottomInset > 0 ? 6 : 0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF151819),
        border: Border(
          top: BorderSide(color: Color(0xFF3A3E41), width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: safeBottomPadding),
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              for (int index = 0; index < _items.length; index++)
                Expanded(
                  child: _NavBarItemButton(
                    item: _items[index],
                    isSelected: selectedIndex == index,
                    onTap: () {
                      ref.read(selectedTabIndexProvider.notifier).state = index;
                      context.goNamed(_items[index].route.name);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItemButton extends StatelessWidget {
  const _NavBarItemButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        isSelected ? const Color(0xFFF1EEFF) : const Color(0xFFC0BDCB);

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 52 : 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF342A66)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: foregroundColor, size: 23),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final AppRoute route;
}
