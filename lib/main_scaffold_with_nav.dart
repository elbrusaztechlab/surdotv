import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:surdotv_app/widgets/bottom_nav_bar.dart';

class MainScaffoldWithNav extends StatelessWidget {
  const MainScaffoldWithNav({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: navigationShell,
      ),
      bottomNavigationBar: AppBottomNavBar(
        navigationShell: navigationShell,
      ),
    );
  }
}
