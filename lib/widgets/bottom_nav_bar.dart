import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:go_router/go_router.dart';

import 'package:surdotv_app/core/router/route_constants.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final selectedIndex = AppRoutes.indexFromPath(currentPath);

    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavyBar(
        selectedIndex: selectedIndex,
        showElevation: false,
        itemCornerRadius: 24,
        curve: Curves.easeOut,
        onItemSelected: navigationShell.goBranch,
        items: [
          _item(context, Icons.home_outlined, 'Əsas'),
          _item(context, Icons.info_outline_rounded, 'Haqqımızda'),
          _item(context, Icons.grid_view_rounded, 'Bölmələr'),
          _item(context, Icons.search_rounded, 'Axtarış'),
          _item(context, Icons.mail_outline_rounded, 'Əlaqə'),
        ],
      ),
    );
  }

  BottomNavyBarItem _item(BuildContext context, IconData icon, String title) {
    return BottomNavyBarItem(
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveColor: Colors.black54,
      icon: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          icon,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
      textAlign: TextAlign.center,
    );
  }
}
