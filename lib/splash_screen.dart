import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:surdotv_app/core/router/route_constants.dart';
import 'package:surdotv_app/features/about/viewmodels/about_viewmodel.dart';
import 'package:surdotv_app/features/catalog/viewmodels/catalog_viewmodel.dart';
import 'package:surdotv_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:surdotv_app/features/search/viewmodels/search_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1400);

  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    _controller.forward();

    await Future.wait<void>([
      context.read<HomeViewModel>().fetchHome(),
      context.read<CatalogViewModel>().fetchCatalog(),
      context.read<AboutViewModel>().fetchAbout(),
      context.read<SearchViewModel>().loadRecommendations(),
      Future<void>.delayed(_duration),
    ]);

    if (!mounted) return;
    context.go(AppRoutes.mainHome.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: FadeTransition(
        opacity: _opacity,
        child: Center(
          child: SizedBox(
            width: 150,
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
      ),
    );
  }
}
